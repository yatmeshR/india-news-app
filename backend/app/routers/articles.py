import base64
from datetime import datetime

from bson import ObjectId
from bson.errors import InvalidId
from fastapi import APIRouter, HTTPException, Query, Request

from ..constants import CATEGORY_SLUGS, LANGUAGES
from ..schemas import ArticleOut, FeedPage, article_out

router = APIRouter()


def encode_cursor(published_at: datetime, oid: ObjectId) -> str:
    raw = f"{published_at.isoformat()}|{oid}"
    return base64.urlsafe_b64encode(raw.encode()).decode()


def decode_cursor(cursor: str) -> tuple[datetime, ObjectId]:
    try:
        raw = base64.urlsafe_b64decode(cursor.encode()).decode()
        ts, oid = raw.split("|")
        return datetime.fromisoformat(ts), ObjectId(oid)
    except (ValueError, InvalidId, UnicodeDecodeError):
        raise HTTPException(status_code=400, detail="Invalid cursor")


@router.get("/feed", response_model=FeedPage)
async def feed(
    request: Request,
    category: str = "top",
    state: str | None = None,
    lang: str = "en",
    cursor: str | None = None,
    limit: int = Query(20, ge=1, le=50),
):
    if category not in CATEGORY_SLUGS:
        raise HTTPException(status_code=400, detail="Unknown category")
    if lang not in LANGUAGES:
        raise HTTPException(status_code=400, detail="Unsupported language")

    query: dict = {"language": lang}
    if category != "top":
        query["category"] = category
    if state:
        query["state"] = state
    if cursor:
        ts, oid = decode_cursor(cursor)
        query["$or"] = [
            {"published_at": {"$lt": ts}},
            {"published_at": ts, "_id": {"$lt": oid}},
        ]

    db = request.app.state.db
    cur = db.articles.find(query).sort([("published_at", -1), ("_id", -1)]).limit(limit + 1)
    docs = await cur.to_list(limit + 1)

    next_cursor = None
    if len(docs) > limit:
        docs = docs[:limit]
        last = docs[-1]
        next_cursor = encode_cursor(last["published_at"], last["_id"])
    return FeedPage(items=[article_out(d) for d in docs], next_cursor=next_cursor)


@router.get("/search", response_model=list[ArticleOut])
async def search(
    request: Request,
    q: str = Query(min_length=2, max_length=100),
    lang: str = "en",
    limit: int = Query(20, ge=1, le=50),
):
    db = request.app.state.db
    cur = (
        db.articles.find(
            {"$text": {"$search": q}, "language": lang},
            {"score": {"$meta": "textScore"}},
        )
        .sort([("score", {"$meta": "textScore"}), ("published_at", -1)])
        .limit(limit)
    )
    return [article_out(d) for d in await cur.to_list(limit)]


@router.get("/articles/{article_id}", response_model=ArticleOut)
async def get_article(request: Request, article_id: str):
    try:
        oid = ObjectId(article_id)
    except InvalidId:
        raise HTTPException(status_code=404, detail="Not found")
    doc = await request.app.state.db.articles.find_one({"_id": oid})
    if not doc:
        raise HTTPException(status_code=404, detail="Not found")
    return article_out(doc)
