"""Structured logging configuration for the application"""

import logging
import sys
import json
from datetime import datetime
from typing import Any, Dict
from pythonjsonlogger import jsonlogger
from app.core.config import settings


class CustomJsonFormatter(jsonlogger.JsonFormatter):
    """Custom JSON formatter with additional context"""
    
    def add_fields(self, log_record: Dict[str, Any], record: logging.LogRecord, message_dict: Dict[str, Any]) -> None:
        """Add custom fields to log record"""
        super().add_fields(log_record, record, message_dict)
        log_record['timestamp'] = datetime.utcnow().isoformat()
        log_record['level'] = record.levelname
        log_record['logger'] = record.name
        if record.exc_info:
            log_record['exception'] = self.formatException(record.exc_info)


def setup_logging() -> logging.Logger:
    """
    Configure structured logging for the application.
    
    Returns:
        logging.Logger: Configured logger instance
    """
    # Create logger
    logger = logging.getLogger(settings.PROJECT_NAME)
    logger.setLevel(getattr(logging, settings.LOG_LEVEL))
    
    # Remove existing handlers
    logger.handlers.clear()
    
    # Create console handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(getattr(logging, settings.LOG_LEVEL))
    
    # Set formatter based on configuration
    if settings.LOG_FORMAT.lower() == "json":
        formatter = CustomJsonFormatter('%(timestamp)s %(level)s %(name)s %(message)s')
    else:
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
    
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)
    
    # Configure library loggers
    logging.getLogger("uvicorn").setLevel(logging.WARNING)
    logging.getLogger("uvicorn.error").setLevel(logging.ERROR)
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)
    
    logger.info(
        f"{settings.PROJECT_NAME} v{settings.VERSION} logging initialized",
        extra={
            "environment": settings.ENVIRONMENT,
            "log_level": settings.LOG_LEVEL,
            "log_format": settings.LOG_FORMAT
        }
    )
    
    return logger


# Initialize logger
logger = setup_logging()
