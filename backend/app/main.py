"""FastAPI application entry point"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.endpoints import predict, health
from app.core.config import settings
from app.core.logging import logger
from app.core.error_handler import setup_error_handlers
from app.core.middleware import setup_middleware


# Create FastAPI application
app = FastAPI(
    title=settings.PROJECT_NAME,
    description="Agricultural Crop Prediction Service for Rwanda",
    version=settings.VERSION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Setup middleware
setup_middleware(app)

# Setup error handlers
setup_error_handlers(app)

# CORS configuration
if settings.BACKEND_CORS_ORIGINS:
    cors_origins = settings.get_cors_origins
    app.add_middleware(
        CORSMiddleware,
        allow_origins=cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    logger.info(f"CORS configured for origins: {', '.join(cors_origins)}")

# Include routers
app.include_router(predict.router, prefix=settings.API_V1_STR, tags=["prediction"])
app.include_router(health.router, prefix=settings.API_V1_STR, tags=["health"])

# Log startup
logger.info(
    f"{settings.PROJECT_NAME} v{settings.VERSION} started successfully",
    extra={
        "environment": settings.ENVIRONMENT,
        "api_version": settings.API_V1_STR,
        "log_level": settings.LOG_LEVEL
    }
)


@app.get("/")
async def root():
    """Root endpoint with API information"""
    return {
        "message": f"Welcome to {settings.PROJECT_NAME}",
        "version": settings.VERSION,
        "environment": settings.ENVIRONMENT,
        "docs": "/docs",
        "health": f"{settings.API_V1_STR}/health"
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host=settings.API_HOST,
        port=settings.API_PORT,
        reload=settings.ENVIRONMENT == "development",
        log_level=settings.LOG_LEVEL.lower()
    )
