from fastapi import APIRouter, Request

from ..constants import CATEGORIES, LANGUAGES, STATE_KEYWORDS
from ..schemas import CategoryOut

router = APIRouter()


@router.get("/healthz")
async def healthz(request: Request):
    try:
        await request.app.state.db.command("ping")
        return {"status": "ok", "db": "up"}
    except Exception:
        return {"status": "degraded", "db": "down"}


@router.get("/v1/categories", response_model=list[CategoryOut])
async def categories():
    return [CategoryOut(slug=s, name=n) for s, n in CATEGORIES]


@router.get("/v1/meta")
async def meta():
    return {"languages": LANGUAGES, "states": sorted(STATE_KEYWORDS)}
