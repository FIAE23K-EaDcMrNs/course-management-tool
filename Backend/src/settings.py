"""Application settings using pydantic-settings."""

from typing import Optional
from pydantic import BaseModel, Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class OllamaSettings(BaseModel):
    """Ollama configuration settings."""

    url: str = Field(description="Ollama server URL")
    model: str = Field(description="Ollama model to use")


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # API Configuration
    app_name: str = Field(default="Backend API", description="Application name")
    app_version: str = Field(default="0.0.0", description="Application version")
    debug: bool = Field(default=False, description="Enable debug mode")

    # Ollama Configuration
    ollama: Optional[OllamaSettings] = Field(
        default=None,
        description="Ollama configuration"
    )

    # Logging Configuration
    log_level: str = Field(default="INFO", description="Logging level")


# Global settings instance
settings = Settings()
