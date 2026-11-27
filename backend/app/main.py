import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import settings
from .db import ensure_indexes, make_client
from .routers import articles, meta

logging.basicConfig(level=logging.INFO)
log = logging.getLogger("newsapp")


@asynccontextmanager
async def lifespan(app: FastAPI):
    client = make_client()
    app.state.client = client
    app.state.db = client[settings.mongo_db]
    try:
        await ensure_indexes(app.state.db)
    except Exception:  # API should still boot; /healthz will report DB state
        log.exception("Could not ensure indexes at startup")
    yield
    await client.close()


app = FastAPI(title="India News API", version="0.1.0", lifespan=lifespan)

origins = [o.strip() for o in settings.cors_origins.split(",")]
app.add_middleware(CORSMiddleware, allow_origins=origins, allow_methods=["GET"], allow_headers=["*"])

app.include_router(meta.router)
app.include_router(articles.router, prefix="/v1")
