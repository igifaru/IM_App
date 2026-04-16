"""Pydantic data models and schemas for API requests/responses"""

from pydantic import BaseModel, Field, validator
from typing import Optional, List, Dict, Any
from datetime import datetime


class PredictionRequest(BaseModel):
    """Request model for crop prediction"""
    
    province: str = Field(..., description="Province name", min_length=1, max_length=100)
    district: str = Field(..., description="District name", min_length=1, max_length=100)
    season: str = Field(..., description="Growing season (Season A, Season B, etc.)", min_length=1, max_length=100)
    slope: str = Field(..., description="Whether land is on a slope (Yes/No)", min_length=1, max_length=100)
    seeds: str = Field(..., description="Type of seeds used", min_length=1, max_length=100)
    inorganic_fert: int = Field(..., description="Using chemical fertilizer (1=Yes, 0=No)", ge=0, le=1)
    organic_fert: int = Field(..., description="Using compost/manure (1=Yes, 0=No)", ge=0, le=1)
    used_lime: int = Field(..., description="Applied lime (1=Yes, 0=No)", ge=0, le=1)
    crop: Optional[str] = Field(None, description="Crop farmer wants to plant (for smart consultant mode)")
    
    class Config:
        schema_extra = {
            "example": {
                "province": "Kigali",
                "district": "Gasabo",
                "season": "Season A",
                "slope": "No",
                "seeds": "Improved seeds",
                "inorganic_fert": 1,
                "organic_fert": 0,
                "used_lime": 0,
                "crop": "Maize"
            }
        }


class PredictionResponse(BaseModel):
    """Response model for crop prediction"""
    
    recommended_crop: str = Field(..., description="Recommended crop type")
    confidence_score: Optional[float] = Field(None, description="Confidence score (0.0-1.0)", ge=0.0, le=1.0)
    low_confidence: bool = Field(False, description="Whether confidence is below threshold")
    confidence_disclaimer: Optional[str] = Field(None, description="Disclaimer if confidence is low")
    status: str = Field(..., description="Status of prediction (success/warning/error)")
    advice: Optional[str] = Field(None, description="Expert advice for the recommended crop")
    timestamp: datetime = Field(default_factory=datetime.utcnow, description="Prediction timestamp")
    
    class Config:
        schema_extra = {
            "example": {
                "recommended_crop": "Maize",
                "confidence_score": 0.76,
                "low_confidence": False,
                "confidence_disclaimer": None,
                "status": "success",
                "advice": "Plant in rows with 75cm between rows...",
                "timestamp": "2024-01-15T10:30:00"
            }
        }


class MetadataResponse(BaseModel):
    """Response model for metadata endpoint"""
    
    provinces: List[str] = Field(..., description="List of supported provinces")
    districts: List[str] = Field(..., description="List of supported districts")
    seasons: List[str] = Field(..., description="List of supported seasons")
    slopes: List[str] = Field(..., description="List of supported slope values")
    seeds: List[str] = Field(..., description="List of supported seed types")
    crops: List[str] = Field(..., description="List of supported crops")
    
    class Config:
        schema_extra = {
            "example": {
                "provinces": ["Kigali", "Northern Province", "Southern Province"],
                "districts": ["Gasabo", "Kicukiro", "Nyarugenge"],
                "seasons": ["Season A", "Season B"],
                "slopes": ["Yes", "No"],
                "seeds": ["Improved seeds", "Traditional seeds"],
                "crops": ["Maize", "Paddy rice", "Bush bean", "Climbing bean"]
            }
        }


class ErrorResponse(BaseModel):
    """Response model for errors"""
    
    error_code: str = Field(..., description="Machine-readable error code")
    message: str = Field(..., description="User-friendly error message")
    reference_id: str = Field(..., description="Error reference ID for support")
    details: Dict[str, Any] = Field(default_factory=dict, description="Additional error details")
    timestamp: datetime = Field(default_factory=datetime.utcnow, description="Error timestamp")
    
    class Config:
        schema_extra = {
            "example": {
                "error_code": "VALIDATION_ERROR",
                "message": "Field 'district' must be one of: Gasabo, Kicukiro, Nyarugenge",
                "reference_id": "550e8400-e29b-41d4-a716-446655440000",
                "details": {
                    "field": "district",
                    "allowed_values": ["Gasabo", "Kicukiro", "Nyarugenge"]
                },
                "timestamp": "2024-01-15T10:30:00"
            }
        }

