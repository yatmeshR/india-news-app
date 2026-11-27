"""One-shot ingestion run: fetch all feeds, dedupe, classify, summarise, store.

Run:  python -m app.ingest.run
Scheduled in production by .github/workflows/ingest.yml (free), not a long-running worker.
"""

import asyncio
import calendar
import logging
from datetime import datetime, timedelta, timezone
from pathlib import Path

import feedparser
import httpx
import yaml
from bs4 import BeautifulSoup
from pymongo.errors import DuplicateKeyError

from ..config import settings
from ..db import ensure_indexes, make_client
from .classify import classify_category, detect_state
from .dedupe import NearDupIndex
from .text import clean_html, summarise, url_hash

log = logging.getLogger("ingest")
SOURCES_FILE = Path(__file__).with_name("sources.yaml")
HEADERS = {"User-Agent": "IndiaNewsApp/0.1 (RSS reader; headline+link only)"}


def extract_image(entry) -> str | None:
    candidates: list[str] = []
    for key in ("media_content", "media_thumbnail"):
        candidates += [m.get("url", "") for m in entry.get(key, []) or []]
    candidates += [
        e.get("href", "") for e in entry.get("enclosures", []) or [] if str(e.get("type", "")).startswith("image")
    ]
    html = entry.get("summary", "") or ""
    for c in entry.get("content", []) or []:
        html += c.get("value", "")
    if html:
        img = BeautifulSoup(html, "html.parser").find("img")
        if img and img.get("src"):
            candidates.append(img["src"])
    for url in candidates:
        if url.startswith("https://"):
            return url
        if url.startswith("http://"):  # Android blocks cleartext; try https
            return "https://" + url[len("http://"):]
    return None


def entry_time(entry) -> datetime:
    parsed = entry.get("published_parsed") or entry.get("updated_parsed")
    if parsed:
        return datetime.fromtimestamp(calendar.timegm(parsed), tz=timezone.utc)
    return datetime.now(timezone.utc)


async def fetch(client: httpx.AsyncClient, sem: asyncio.Semaphore, source: dict):
    async with sem:
        try:
            resp = await client.get(source["url"], headers=HEADERS, follow_redirects=True, timeout=20)
            resp.raise_for_status()
            return source, feedparser.parse(resp.content)
        except Exception as exc:
            log.warning("FAILED %s (%s): %s", source["name"], source["url"], exc)
            return source, None


async def main() -> None:
    sources = yaml.safe_load(SOURCES_FILE.read_text(encoding="utf-8"))["sources"]
    mongo = make_client()
    db = mongo[settings.mongo_db]
    await ensure_indexes(db)

    now = datetime.now(timezone.utc)
    oldest = now - timedelta(days=settings.retention_days)

    # Near-duplicate index seeded with the last 48h of titles
    recent = db.articles.find({"published_at": {"$gte": now - timedelta(hours=48)}}, {"title": 1})
    near = NearDupIndex()
    async for doc in recent:
        near.add(doc["title"])

    sem = asyncio.Semaphore(6)
    async with httpx.AsyncClient() as http:
        results = await asyncio.gather(*(fetch(http, sem, s) for s in sources))

    stats = {"feeds_ok": 0, "feeds_failed": 0, "new": 0, "dup_url": 0, "dup_title": 0, "old": 0}
    for source, feed in results:
        if feed is None or (feed.bozo and not feed.entries):
            stats["feeds_failed"] += 1
            continue
        stats["feeds_ok"] += 1
        for entry in feed.entries:
            link, title = entry.get("link"), clean_html(entry.get("title", ""))
            if not link or not title:
                continue
            published = entry_time(entry)
            if published < oldest:
                stats["old"] += 1
                continue
            if near.is_duplicate(title):
                stats["dup_title"] += 1
                continue

            raw_desc = entry.get("summary", "") or (entry.get("content") or [{}])[0].get("value", "")
            summary = summarise(title, raw_desc, settings.summary_words)
            doc = {
                "title": title,
                "summary": summary,
                "image_url": extract_image(entry),
                "source": source["name"],
                "url": link,
                "url_hash": url_hash(link),
                "language": source["language"],
                "category": classify_category(source["category"], title, summary),
                "state": detect_state(source.get("state"), title, summary),
                "published_at": published,
                "ingested_at": now,
            }
            try:
                await db.articles.insert_one(doc)
                near.add(title)
                stats["new"] += 1
            except DuplicateKeyError:
                stats["dup_url"] += 1

    log.info("Ingest done: %s", stats)
    print(stats)
    await mongo.close()


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    asyncio.run(main())
