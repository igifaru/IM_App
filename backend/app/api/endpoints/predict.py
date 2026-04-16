from fastapi import APIRouter, HTTPException
from app.models.prediction_schema import PredictionRequest, PredictionResponse, MetadataResponse
from app.services.model_service import model_service

router = APIRouter()

ADVICE_MAP = {
    "en": "Based on historical data, this crop is likely to yield high performance in your specific conditions.",
    "fr": "Sur la base des données historiques, cette culture est susceptible de donner des performances élevées dans vos conditions spécifiques.",
    "rw": "Hashingiwe ku makuru y'igihe cyashize, iki gihingwa gishobora kwera neza mu gace kanyu."
}

@router.post("/predict", response_model=PredictionResponse)
async def predict_crop(request: PredictionRequest, lang: str = "en"):
    try:
        prediction = model_service.predict(request.dict())
        advice = ADVICE_MAP.get(lang.lower()[:2], ADVICE_MAP["en"])
        return PredictionResponse(
            recommended_crop=prediction,
            status="success",
            advice=advice
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/metadata", response_model=MetadataResponse)
async def get_metadata():
    try:
        metadata = model_service.get_metadata()
        return MetadataResponse(**metadata)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
