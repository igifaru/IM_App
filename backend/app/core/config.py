from pydantic_settings import BaseSettings
from typing import List

class Settings(BaseSettings):
    PROJECT_NAME: str = "Igisubizo Muhinzi API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # CORS
    BACKEND_CORS_ORIGINS: List[str] = ["*"]
    
    # Model Paths
    MODEL_PATH: str = "../models/crop_model_seasonal.pkl"
    ENCODER_PATH: str = "../models/encoders_seasonal.pkl"

    class Config:
        case_sensitive = True

settings = Settings()
