from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware

from . import db
from .config import settings
from .routers import (
    appointments,
    auth,
    dietitians,
    files,
    me,
    meals,
    messages,
    notifications,
    pro,
    progress,
    record,
    recipes,
)
from .sms import get_sms


@asynccontextmanager
async def lifespan(_: FastAPI):
    settings.check_production()
    get_sms()  # échoue au démarrage si le fournisseur SMS est inconnu
    db.init_pool()
    yield
    db.close_pool()


app = FastAPI(title="Tchihali API", version="0.1.0", lifespan=lifespan, docs_url="/docs" if settings.env == "dev" else None, redoc_url=None, openapi_url="/openapi.json" if settings.env == "dev" else None)

MAX_BODY = (settings.max_upload_mb + 1) * 1024 * 1024


@app.middleware("http")
async def security(request: Request, call_next):
    size = request.headers.get("content-length")
    if size and size.isdigit() and int(size) > MAX_BODY:
        return JSONResponse({"detail": "Requête trop volumineuse"}, status_code=413)
    response = await call_next(request)
    response.headers.setdefault("X-Content-Type-Options", "nosniff")
    response.headers.setdefault("Referrer-Policy", "no-referrer")
    response.headers.setdefault("X-Frame-Options", "DENY")
    # Les réponses de l'API contiennent des données de santé : jamais mises en cache (sauf photos, déjà privées).
    if request.url.path.startswith("/v1") and "cache-control" not in response.headers:
        response.headers["Cache-Control"] = "no-store"
    return response


if settings.cors_origins:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=[o.strip() for o in settings.cors_origins.split(",") if o.strip()],
        allow_methods=["*"],
        allow_headers=["*"],
    )

for r in (
    auth.router, me.router, dietitians.router, appointments.router, recipes.router, messages.router,
    files.router, meals.router, progress.router, notifications.router, record.router, pro.router,
):
    app.include_router(r, prefix="/v1")


@app.get("/health")
def health():
    return {"status": "ok"}
