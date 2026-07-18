from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from prometheus_fastapi_instrumentator import Instrumentator
from app.config import settings
from app.database.engine import Base, engine
from app.routes.auth import router as auth_router
from app.routes.overview import router as overview_router
from app.routes.partners import router as partners_router
from app.routes.data import (
    segments_router,
    merchants_router,
    negotiate_router,
    recommendations_router,
)

# Auto-create tables (use Alembic for production migrations)
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
)

# ─── CORS ──────────────────────────────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── Routes ────────────────────────────────────────────────────────────────
PREFIX = "/api/v1"

app.include_router(auth_router, prefix=PREFIX)
app.include_router(overview_router, prefix=PREFIX)
app.include_router(partners_router, prefix=PREFIX)
app.include_router(segments_router, prefix=PREFIX)
app.include_router(merchants_router, prefix=PREFIX)
app.include_router(negotiate_router, prefix=PREFIX)
app.include_router(recommendations_router, prefix=PREFIX)


@app.get("/health")
def health():
    return {"status": "ok", "version": settings.app_version}


# ─── Observability ─────────────────────────────────────────────────────────
# Exposes request count, latency histograms, and in-progress requests at
# /metrics in Prometheus text format. Scraped by the prometheus service
# defined in docker-compose.yml; visualized via the bundled Grafana dashboard.
Instrumentator().instrument(app).expose(app, endpoint="/metrics")
