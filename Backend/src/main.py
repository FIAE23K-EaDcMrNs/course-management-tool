"""FastAPI application entry point."""

import sys
from contextlib import asynccontextmanager
from fastapi import FastAPI, Response
from fastapi.middleware.cors import CORSMiddleware
from loguru import logger
from routes import router
from settings import settings

# Configure loguru logger
logger.remove()  # Remove default handler
logger.add(sys.stderr, level=settings.log_level.upper())

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager."""
    logger.info("Starting up {}", settings.APP_NAME)
    yield
    logger.info("Shutting down {}", settings.APP_NAME)

# Create FastAPI application
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    debug=settings.debug,
    lifespan=lifespan,
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this properly for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routes
app.include_router(router, prefix="/api/v1")

# Root endpoint
@app.get("/api")
async def root():
    """Root endpoint."""
    return Response(content="")


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=5689,
        reload=settings.debug,
    )
