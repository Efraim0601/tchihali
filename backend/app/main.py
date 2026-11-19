from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from . import db
from .config import settings
from .routers import appointments, auth, dietitians, me, messages, recipes
from .sms import get_sms


@asynccontextmanager
async def lifespan(_: FastAPI):
    settings.check_production()
    get_sms()  # échoue au démarrage si le fournisseur SMS est inconnu
    db.init_pool()
    yield
    db.close_pool()


app = FastAPI(title="Tchihali API", version="0.1.0", lifespan=lifespan, docs_url="/docs" if settings.env == "dev" else None, redoc_url=None, openapi_url="/openapi.json" if settings.env == "dev" else None)

if settings.cors_origins:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=[o.strip() for o in settings.cors_origins.split(",") if o.strip()],
        allow_methods=["*"],
        allow_headers=["*"],
    )

for r in (auth.router, me.router, dietitians.router, appointments.router, recipes.router, messages.router):
    app.include_router(r, prefix="/v1")


@app.get("/health")
def health():
    return {"status": "ok"}
