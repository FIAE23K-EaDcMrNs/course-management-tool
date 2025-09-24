"""Application settings using pydantic-settings."""

from typing import Optional
from pydantic import BaseModel, Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class OllamaSettings(BaseModel):
    """Ollama configuration settings."""

    url: str = Field(description="Ollama server URL")
    model: str = Field(description="Ollama model to use")


class Settings(BaseSettings):
    """Application settings loaded from .env file and environment variables."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # Static application configuration (not configurable)
    APP_NAME: str = "Backend API"
    APP_VERSION: str = "0.1.0"

    # Configurable settings
    debug: bool = Field(default=False, description="Enable debug mode")
    log_level: str = Field(default="INFO", description="Logging level")

    # Ollama Configuration
    ollama: Optional[OllamaSettings] = Field(
        default=None,
        description="Ollama configuration"
    )


# Global settings instance
settings = Settings()
