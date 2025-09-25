"""API routes for the application."""

from fastapi import APIRouter
from loguru import logger

from models import HealthResponse
from settings import settings

router = APIRouter()

@router.get("/health", response_model=HealthResponse)
async def health_check() -> HealthResponse:
    """Health check endpoint."""
    logger.info("Health check endpoint called")

    return HealthResponse(
        status="healthy",
        message=f"{settings.app_name} v{settings.app_version} is running"
    )
