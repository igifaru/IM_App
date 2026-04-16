"""Application configuration management"""

import os
from typing import List, Optional
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings loaded from environment variables"""
    
    # Project Metadata
    PROJECT_NAME: str = "Igisubizo Muhinzi API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")
    
    # Server Configuration
    API_HOST: str = os.getenv("API_HOST", "0.0.0.0")
    API_PORT: int = int(os.getenv("API_PORT", "8000"))
    
    # CORS Configuration
    BACKEND_CORS_ORIGINS: str = os.getenv("BACKEND_CORS_ORIGINS", "*")
    
    @property
    def get_cors_origins(self) -> List[str]:
        """Parse CORS origins from comma-separated string"""
        if self.BACKEND_CORS_ORIGINS == "*":
            return ["*"]
        return [origin.strip() for origin in self.BACKEND_CORS_ORIGINS.split(",")]
    
    # Logging Configuration
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")
    LOG_FORMAT: str = os.getenv("LOG_FORMAT", "json")  # json or text
    
    # Project Root Calculation (moves up from backend/app/core/ to project root)
    BASE_DIR: str = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
    
    # Model Paths - use model_validator to avoid pydantic issues
    _model_path: str = ""
    _encoder_path: str = ""
    
    @property
    def MODEL_PATH(self) -> str:
        if not self._model_path:
            self._model_path = os.getenv("MODEL_PATH", os.path.join(self.BASE_DIR, "models/crop_model_seasonal.pkl"))
        return self._model_path
    
    @property
    def ENCODER_PATH(self) -> str:
        if not self._encoder_path:
            self._encoder_path = os.getenv("ENCODER_PATH", os.path.join(self.BASE_DIR, "models/encoders_seasonal.pkl"))
        return self._encoder_path
    
    # Database Configuration (Optional for Phase 1)
    DATABASE_URL: Optional[str] = os.getenv("DATABASE_URL", None)
    
    # Cache Configuration (Optional for Phase 1)
    CACHE_URL: Optional[str] = os.getenv("CACHE_URL", None)
    
    # API Configuration
    API_KEY_SECRET: Optional[str] = os.getenv("API_KEY_SECRET", None)
    RATE_LIMIT_PER_MINUTE: int = int(os.getenv("RATE_LIMIT_PER_MINUTE", "100"))
    
    # Model Configuration
    CONFIDENCE_THRESHOLD: float = float(os.getenv("CONFIDENCE_THRESHOLD", "0.3"))
    
    # AI Configuration
    GROQ_API_KEY: Optional[str] = os.getenv("GROQ_API_KEY", None)
    
    # Request Configuration
    REQUEST_TIMEOUT_SECONDS: int = int(os.getenv("REQUEST_TIMEOUT_SECONDS", "30"))
    MAX_REQUEST_SIZE_KB: int = int(os.getenv("MAX_REQUEST_SIZE_KB", "10"))

    class Config:
        case_sensitive = True
        env_file = ".env"
        env_file_encoding = "utf-8"

    def validate_required_paths(self) -> None:
        """Validate that required model files exist"""
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
