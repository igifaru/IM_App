"""Smart Consultant response models"""

from pydantic import BaseModel, Field
from datetime import datetime
from typing import List


class FarmerChoiceResponse(BaseModel):
    """Farmer's crop choice validation result"""
    
    crop: str = Field(..., description="Crop selected by farmer")
    confidence_score: float = Field(..., description="Confidence score (0.0-1.0)", ge=0.0, le=1.0)
    status: str = Field(..., description="Status: good, moderate, or poor")
    status_color: str = Field(..., description="Color indicator: green, yellow, or red")
    validation_message: str = Field(..., description="Validation message for farmer")
    
    class Config:
        schema_extra = {
            "example": {
                "crop": "Maize",
                "confidence_score": 0.65,
                "status": "moderate",
                "status_color": "yellow",
                "validation_message": "Maize is moderately suitable for your conditions"
            }
        }


class RecommendationResponse(BaseModel):
    """Crop recommendation with ranking"""
    
    rank: int = Field(..., description="Ranking (1=best, 2=second, 3=third)", ge=1, le=3)
    crop: str = Field(..., description="Recommended crop name")
    confidence_score: float = Field(..., description="Confidence score (0.0-1.0)", ge=0.0, le=1.0)
    reason: str = Field(..., description="Brief reason for recommendation")
    
    class Config:
        schema_extra = {
            "example": {
                "rank": 1,
                "crop": "Bush bean",
                "confidence_score": 0.89,
                "reason": "High success rate in your district during this season"
            }
        }


class AIInterpretationResponse(BaseModel):
    """AI-generated interpretation"""
    
    text: str = Field(..., description="Natural language interpretation")
    language: str = Field(..., description="Language code (en/fr/rw)")
    generated_at: datetime = Field(default_factory=datetime.utcnow, description="Generation timestamp")
    
    class Config:
        schema_extra = {
            "example": {
                "text": "Amahitamo yawe ya Ibigori ni meza ariko Ibishyimbo bishobora kuba byiza cyane...",
                "language": "rw",
                "generated_at": "2026-04-16T10:30:00Z"
            }
        }


class MetadataResponse(BaseModel):
    """Analysis metadata"""
    
    total_crops_analyzed: int = Field(..., description="Total number of crops analyzed")
    analysis_timestamp: datetime = Field(default_factory=datetime.utcnow, description="Analysis timestamp")
    
    class Config:
        schema_extra = {
            "example": {
                "total_crops_analyzed": 21,
                "analysis_timestamp": "2026-04-16T10:30:00Z"
            }
        }


class SmartConsultantResponse(BaseModel):
    """Complete smart consultant response"""
    
    farmer_choice: FarmerChoiceResponse = Field(..., description="Farmer's crop choice validation")
    top_recommendations: List[RecommendationResponse] = Field(..., description="Top 3 crop recommendations")
    ai_interpretation: AIInterpretationResponse = Field(..., description="AI-powered interpretation")
    metadata: MetadataResponse = Field(..., description="Analysis metadata")
    
    class Config:
        schema_extra = {
            "example": {
                "farmer_choice": {
                    "crop": "Maize",
                    "confidence_score": 0.65,
                    "status": "moderate",
                    "status_color": "yellow",
                    "validation_message": "Maize is moderately suitable for your conditions"
                },
                "top_recommendations": [
                    {
                        "rank": 1,
                        "crop": "Bush bean",
                        "confidence_score": 0.89,
                        "reason": "High success rate in your district during this season"
                    },
                    {
                        "rank": 2,
                        "crop": "Irish potato",
                        "confidence_score": 0.84,
                        "reason": "Excellent match for your slope and fertilizer use"
                    },
                    {
                        "rank": 3,
                        "crop": "Climbing bean",
                        "confidence_score": 0.78,
                        "reason": "Good alternative with similar growing requirements"
                    }
                ],
                "ai_interpretation": {
                    "text": "Your choice of Maize is moderate. However, Bush bean shows higher success...",
                    "language": "en",
                    "generated_at": "2026-04-16T10:30:00Z"
                },
                "metadata": {
                    "total_crops_analyzed": 21,
                    "analysis_timestamp": "2026-04-16T10:30:00Z"
                }
            }
        }
