from pymongo import ASCENDING, DESCENDING, TEXT, AsyncMongoClient
from pymongo.asynchronous.database import AsyncDatabase

from .config import settings


def make_client() -> AsyncMongoClient:
    return AsyncMongoClient(settings.mongo_uri, tz_aware=True, serverSelectionTimeoutMS=8000)


async def ensure_indexes(db: AsyncDatabase) -> None:
    articles = db.articles
    await articles.create_index([("url_hash", ASCENDING)], unique=True, name="uniq_url_hash")
    await articles.create_index(
        [("language", ASCENDING), ("category", ASCENDING), ("published_at", DESCENDING), ("_id", DESCENDING)],
        name="feed_by_category",
    )
    await articles.create_index(
        [("language", ASCENDING), ("state", ASCENDING), ("published_at", DESCENDING), ("_id", DESCENDING)],
        name="feed_by_state",
    )
    await articles.create_index(
        [("language", ASCENDING), ("published_at", DESCENDING), ("_id", DESCENDING)],
        name="feed_latest",
    )
    # Auto-delete old articles to stay inside the free 512 MB Atlas tier.
    await articles.create_index(
        [("ingested_at", ASCENDING)],
        expireAfterSeconds=settings.retention_days * 86400,
        name="ttl_ingested_at",
    )
    await articles.create_index(
        [("title", TEXT), ("summary", TEXT)],
        default_language="none",  # no stemming: works for Hindi too
        language_override="text_lang",  # our "language" field holds "hi"/"en", which Mongo would reject
        name="text_search",
    )
