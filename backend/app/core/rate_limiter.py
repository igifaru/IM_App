"""Rate limiting for API requests"""

import time
from typing import Dict, Tuple
from collections import defaultdict
from fastapi import Request, HTTPException, status
from app.core.logging import logger
from app.core.config import settings


class RateLimiter:
    """Token bucket rate limiter"""
    
    def __init__(self, requests_per_minute: int = 100):
        """
        Initialize rate limiter.
        
        Args:
            requests_per_minute: Maximum requests per minute per client
        """
        self.requests_per_minute = requests_per_minute
        self.requests_per_second = requests_per_minute / 60.0
        # Store: {client_id: (tokens, last_update_time)}
        self.buckets: Dict[str, Tuple[float, float]] = defaultdict(
            lambda: (float(self.requests_per_minute), time.time())
        )
        logger.info(f"Rate limiter initialized: {requests_per_minute} req/min")
    
    def _get_client_id(self, request: Request) -> str:
        """
        Get client identifier from request.
        
        Args:
            request: HTTP request
        
        Returns:
            Client identifier (IP address or API key)
        """
        # Try to get from X-Forwarded-For header (proxy)
        if "x-forwarded-for" in request.headers:
            return request.headers["x-forwarded-for"].split(",")[0].strip()
        
        # Fall back to client IP
        if request.client:
            return request.client.host
        
        return "unknown"
    
    def _refill_bucket(self, client_id: str) -> Tuple[float, float]:
        """
        Refill token bucket based on elapsed time.
        
        Args:
            client_id: Client identifier
        
        Returns:
            Tuple of (tokens, current_time)
        """
        tokens, last_update = self.buckets[client_id]
        now = time.time()
        elapsed = now - last_update
        
        # Add tokens based on elapsed time
        tokens = min(
            float(self.requests_per_minute),
            tokens + elapsed * self.requests_per_second
        )
        
        return tokens, now
    
    def is_allowed(self, request: Request) -> Tuple[bool, Dict[str, str]]:
        """
        Check if request is allowed under rate limit.
        
        Args:
            request: HTTP request
        
        Returns:
            Tuple of (is_allowed, headers)
        """
        client_id = self._get_client_id(request)
        tokens, now = self._refill_bucket(client_id)
        
        # Calculate rate limit info
        limit = self.requests_per_minute
        remaining = int(tokens)
        reset_time = int(now + (self.requests_per_minute - tokens) / self.requests_per_second)
        
        headers = {
            "X-RateLimit-Limit": str(limit),
            "X-RateLimit-Remaining": str(max(0, remaining)),
            "X-RateLimit-Reset": str(reset_time)
        }
        
        if tokens < 1:
            logger.warning(
                f"Rate limit exceeded for client: {client_id}",
                extra={
                    "client_id": client_id,
                    "limit": limit,
                    "reset_time": reset_time
                }
            )
            return False, headers
        
        # Consume token
        tokens -= 1
        self.buckets[client_id] = (tokens, now)
        
        logger.debug(
            f"Rate limit check passed for client: {client_id}",
            extra={
                "client_id": client_id,
                "remaining": remaining - 1,
                "limit": limit
            }
        )
        
        return True, headers
    
    def reset_client(self, client_id: str) -> None:
        """
        Reset rate limit for a client.
        
        Args:
            client_id: Client identifier
        """
        self.buckets[client_id] = (float(self.requests_per_minute), time.time())
        logger.info(f"Rate limit reset for client: {client_id}")


# Global rate limiter instance
rate_limiter = RateLimiter(
    requests_per_minute=settings.RATE_LIMIT_PER_MINUTE
)


async def check_rate_limit(request: Request) -> None:
    """
    Check rate limit for request.
    
    Args:
        request: HTTP request
    
    Raises:
        HTTPException: If rate limit exceeded
    """
    is_allowed, headers = rate_limiter.is_allowed(request)
    
    # Store headers in request state for middleware to add to response
    request.state.rate_limit_headers = headers
    
    if not is_allowed:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Rate limit exceeded",
            headers={
                "Retry-After": headers["X-RateLimit-Reset"],
                **headers
            }
        )
