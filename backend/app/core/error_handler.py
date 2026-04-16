"""Global error handling middleware and utilities"""

from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from app.core.exceptions import IgisubizoException
from app.core.logging import logger
from typing import Dict, Any


async def global_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """
    Global exception handler for all unhandled exceptions.
    
    Args:
        request: The HTTP request
        exc: The exception that was raised
    
    Returns:
        JSON response with error details
    """
    if isinstance(exc, IgisubizoException):
        # Handle custom Igisubizo exceptions
        logger.error(
            f"Igisubizo exception: {exc.error_code}",
            extra={
                "error_code": exc.error_code,
                "error_message": exc.message,
                "reference_id": exc.reference_id,
                "status_code": exc.status_code
            }
        )
        return JSONResponse(
            status_code=exc.status_code,
            content=exc.to_dict()
        )
    
    # Handle unexpected exceptions
    reference_id = None
    if isinstance(exc, IgisubizoException):
        reference_id = exc.reference_id
    
    logger.error(
        f"Unexpected exception: {type(exc).__name__}",
        extra={
            "exception_type": type(exc).__name__,
            "error_message": str(exc),
            "reference_id": reference_id
        },
        exc_info=True
    )
    
    # Return generic error response
    from uuid import uuid4
    error_ref = str(uuid4())
    
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "error_code": "INTERNAL_SERVER_ERROR",
            "message": "An unexpected error occurred. Please contact support with the reference ID.",
            "reference_id": error_ref,
            "details": {}
        }
    )


async def validation_exception_handler(request: Request, exc: RequestValidationError) -> JSONResponse:
    """
    Handle Pydantic validation errors.
    
    Args:
        request: The HTTP request
        exc: The validation error
    
    Returns:
        JSON response with validation error details
    """
    errors = []
    for error in exc.errors():
        field = ".".join(str(x) for x in error["loc"][1:])
        errors.append({
            "field": field,
            "message": error["msg"],
            "type": error["type"]
        })
    
    logger.warning(
        "Validation error",
        extra={
            "errors": errors,
            "path": str(request.url.path)
        }
    )
    
    from uuid import uuid4
    error_ref = str(uuid4())
    
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "error_code": "VALIDATION_ERROR",
            "message": "Request validation failed",
            "reference_id": error_ref,
            "details": {"errors": errors}
        }
    )


def setup_error_handlers(app: FastAPI) -> None:
    """
    Setup global error handlers for the FastAPI application.
    
    Args:
        app: FastAPI application instance
    """
    app.add_exception_handler(IgisubizoException, global_exception_handler)
    app.add_exception_handler(RequestValidationError, validation_exception_handler)
    app.add_exception_handler(Exception, global_exception_handler)
    
    logger.info("Error handlers configured")
