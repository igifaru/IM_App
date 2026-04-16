"""Application configuration management"""

import os
from typing import List, Optional
from pydantic_settings import BaseSettings
from functools import lru_cache

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))


class Settings(BaseSettings):
    """Application settings loaded from environment variables"""

    # Project Metadata
    PROJECT_NAME: str = "Igisubizo Muhinzi API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    ENVIRONMENT: str = "development"

    # Server Configuration
    API_HOST: str = "0.0.0.0"
    API_PORT: int = 8000

    # CORS Configuration
    BACKEND_CORS_ORIGINS: str = "*"

    @property
    def get_cors_origins(self) -> List[str]:
        if self.BACKEND_CORS_ORIGINS == "*":
            return ["*"]
        return [origin.strip() for origin in self.BACKEND_CORS_ORIGINS.split(",")]

    # Logging Configuration
    LOG_LEVEL: str = "INFO"
    LOG_FORMAT: str = "json"

    # Model Paths — stored as plain fields, resolved to absolute paths at startup
    MODEL_PATH: str = os.path.join(BASE_DIR, "models/crop_model_seasonal.pkl")
    ENCODER_PATH: str = os.path.join(BASE_DIR, "models/encoders_seasonal.pkl")

    # Database Configuration (Optional)
    DATABASE_URL: Optional[str] = None

    # Cache Configuration (Optional)
    CACHE_URL: Optional[str] = None

    # API Configuration
    API_KEY_SECRET: Optional[str] = None
    RATE_LIMIT_PER_MINUTE: int = 100

    # Model Configuration
    CONFIDENCE_THRESHOLD: float = 0.3

    # AI Configuration
    GROQ_API_KEY: Optional[str] = None

    # Request Configuration
    REQUEST_TIMEOUT_SECONDS: int = 30
    MAX_REQUEST_SIZE_KB: int = 10

    model_config = {
        "case_sensitive": True,
        "env_file": ".env",
        "env_file_encoding": "utf-8",
    }

    def resolve_model_paths(self) -> None:
        """Convert relative model paths to absolute paths if needed"""
        if not os.path.isabs(self.MODEL_PATH):
            object.__setattr__(self, "MODEL_PATH", os.path.join(BASE_DIR, self.MODEL_PATH))
        if not os.path.isabs(self.ENCODER_PATH):
            object.__setattr__(self, "ENCODER_PATH", os.path.join(BASE_DIR, self.ENCODER_PATH))

    def validate_required_paths(self) -> None:
        """Validate that required model files exist"""
        self.resolve_model_paths()
        if not os.path.exists(self.MODEL_PATH):
            raise FileNotFoundError(f"Model file not found at {self.MODEL_PATH}")
        if not os.path.exists(self.ENCODER_PATH):
            raise FileNotFoundError(f"Encoder file not found at {self.ENCODER_PATH}")


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance"""
    settings = Settings()
    settings.validate_required_paths()
    return settings


# Global settings instance
settings = get_settings()
