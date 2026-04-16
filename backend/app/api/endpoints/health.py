from fastapi import APIRouter
from typing import Dict

router = APIRouter()

@router.get("/health", response_model=Dict[str, str])
async def health_check():
    """
    Health check endpoint to verify service availability.
    """
    return {"status": "ok", "message": "Service is running correctly"}
