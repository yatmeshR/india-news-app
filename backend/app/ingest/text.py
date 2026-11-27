import hashlib
import re
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit

from bs4 import BeautifulSoup

_TRACKING = {"utm_source", "utm_medium", "utm_campaign", "utm_term", "utm_content", "ref", "fbclid", "gclid", "cmpid"}
_SENTENCE_SPLIT = re.compile(r"(?<=[.!?।])\s+")
_BOILERPLATE = re.compile(r"\s*(The post .* appeared first on .*|Read more.*|Continue reading.*)$", re.I | re.S)


def clean_html(html: str) -> str:
    if not html:
        return ""
    text = BeautifulSoup(html, "html.parser").get_text(" ")
    text = _BOILERPLATE.sub("", re.sub(r"\s+", " ", text)).strip()
    return text


def normalize_url(url: str) -> str:
    parts = urlsplit(url.strip())
    query = urlencode([(k, v) for k, v in parse_qsl(parts.query) if k.lower() not in _TRACKING])
    path = parts.path.rstrip("/") or "/"
    return urlunsplit((parts.scheme.lower(), parts.netloc.lower(), path, query, ""))


def url_hash(url: str) -> str:
    return hashlib.sha1(normalize_url(url).encode()).hexdigest()


def summarise(title: str, text: str, max_words: int = 60) -> str:
    """Free extractive summary: leading sentences of the feed description, capped at max_words.

    Never returns more than max_words words, and returns "" when the feed gives nothing
    beyond the headline (the app then just shows the headline).
    """
    text = clean_html(text)
    if not text or text.strip().lower() == title.strip().lower():
        return ""
    sentences = [s for s in _SENTENCE_SPLIT.split(text) if s]
    out: list[str] = []
    count = 0
    for sentence in sentences:
        words = sentence.split()
        if count + len(words) > max_words:
            if not out:  # one very long sentence: hard-truncate
                return " ".join(words[:max_words]).rstrip(",;:") + "…"
            break
        out.append(sentence)
        count += len(words)
        if count >= max_words * 0.7:
            break
    return " ".join(out)
