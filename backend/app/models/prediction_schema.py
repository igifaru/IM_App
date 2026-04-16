from pydantic import BaseModel
from typing import Optional

class PredictionRequest(BaseModel):
    province: str
    district: str
    season: str
    slope: str
    seeds: str
    inorganic_fert: int  # 1 for Yes, 0 for No
    organic_fert: int    # 1 for Yes, 0 for No
    used_lime: int      # 1 for Yes, 0 for No

class PredictionResponse(BaseModel):
    recommended_crop: str
    status: str
    advice: Optional[str] = None

class MetadataResponse(BaseModel):
    provinces: list[str]
    districts: list[str]
    seasons: list[str]
    slopes: list[str]
    seeds: list[str]
    crops: list[str]
