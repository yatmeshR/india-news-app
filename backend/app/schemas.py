from datetime import datetime

from pydantic import BaseModel


class ArticleOut(BaseModel):
    id: str
    title: str
    summary: str
    image_url: str | None = None
    source: str
    url: str
    category: str
    state: str | None = None
    language: str
    published_at: datetime


class FeedPage(BaseModel):
    items: list[ArticleOut]
    next_cursor: str | None = None


class CategoryOut(BaseModel):
    slug: str
    name: str


def article_out(doc: dict) -> ArticleOut:
    return ArticleOut(
        id=str(doc["_id"]),
        title=doc["title"],
        summary=doc.get("summary", ""),
        image_url=doc.get("image_url"),
        source=doc["source"],
        url=doc["url"],
        category=doc["category"],
        state=doc.get("state"),
        language=doc["language"],
        published_at=doc["published_at"],
    )
