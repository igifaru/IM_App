"""Health check endpoints"""

from fastapi import APIRouter, status
from typing import Dict, Any
from datetime import datetime
from app.core.logging import logger
from app.services.model_service import model_service

router = APIRouter()


@router.get("/health", status_code=status.HTTP_200_OK)
async def health_check() -> Dict[str, Any]:
    """
    Health check endpoint to verify service availability.
    
    Returns:
        Dictionary with health status and component details
    """
    try:
        # Check model service
        model_healthy = model_service.model is not None and model_service.encoders is not None
        
        health_status = {
            "status": "healthy" if model_healthy else "unhealthy",
            "timestamp": datetime.utcnow().isoformat(),
            "components": {
                "model_service": "healthy" if model_healthy else "unhealthy"
            }
        }
        
        logger.info("Health check passed", extra={"status": health_status["status"]})
        return health_status
    
    except Exception as e:
        logger.error(f"Health check failed: {str(e)}", exc_info=True)
        return {
            "status": "unhealthy",
            "timestamp": datetime.utcnow().isoformat(),
            "error": str(e),
            "components": {
                "model_service": "unhealthy"
            }
        }


@router.get("/health/ready", status_code=status.HTTP_200_OK)
async def readiness_check() -> Dict[str, Any]:
    """
    Kubernetes readiness probe endpoint.
    Returns 200 only when service is ready to accept traffic.
    
    Returns:
        Dictionary with readiness status
    """
    try:
        # Check if model is loaded
        if model_service.model is None or model_service.encoders is None:
            logger.warning("Service not ready: model not loaded")
            return {
                "ready": False,
                "reason": "Model not loaded"
            }
        
        logger.debug("Readiness check passed")
        return {
            "ready": True,
            "timestamp": datetime.utcnow().isoformat()
        }
    
    except Exception as e:
        logger.error(f"Readiness check failed: {str(e)}", exc_info=True)
        return {
            "ready": False,
            "reason": str(e)
        }


@router.get("/health/live", status_code=status.HTTP_200_OK)
async def liveness_check() -> Dict[str, Any]:
    """
    Kubernetes liveness probe endpoint.
    Returns 200 if service is running.
    
    Returns:
        Dictionary with liveness status
    """
    logger.debug("Liveness check passed")
    return {
        "alive": True,
        "timestamp": datetime.utcnow().isoformat()
    }
