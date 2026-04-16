"""API authentication and authorization"""

import os
from typing import Optional, List
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.core.exceptions import AuthenticationError, AuthorizationError
from app.core.logging import logger
from app.core.config import settings


class APIKeyManager:
    """Manages API keys for authentication"""
    
    def __init__(self):
        """Initialize API key manager"""
        self.valid_keys = self._load_api_keys()
        logger.info(f"API Key Manager initialized with {len(self.valid_keys)} keys")
    
    def _load_api_keys(self) -> dict:
        """
        Load API keys from environment variables.
        
        Expected format: API_KEYS=key1:client1,key2:client2
        
        Returns:
            Dictionary mapping API keys to client names
        """
        api_keys_env = os.getenv("API_KEYS", "")
        if not api_keys_env:
            logger.warning("No API keys configured. Authentication disabled.")
            return {}
        
        keys = {}
        try:
            for key_pair in api_keys_env.split(","):
                if ":" in key_pair:
                    key, client = key_pair.strip().split(":", 1)
                    keys[key.strip()] = client.strip()
            logger.info(f"Loaded {len(keys)} API keys")
        except Exception as e:
            logger.error(f"Failed to parse API keys: {str(e)}")
        
        return keys
    
    def validate_key(self, api_key: str) -> str:
        """
        Validate an API key.
        
        Args:
            api_key: The API key to validate
        
        Returns:
            The client name associated with the key
        
        Raises:
            AuthenticationError: If key is invalid
        """
        if not self.valid_keys:
            # If no keys configured, allow all requests
            logger.debug("No API keys configured, allowing request")
            return "default"
        
        if api_key not in self.valid_keys:
            logger.warning(f"Invalid API key attempt: {api_key[:10]}...")
            raise AuthenticationError("Invalid API key")
        
        client = self.valid_keys[api_key]
        logger.debug(f"API key validated for client: {client}")
        return client
    
    def add_key(self, api_key: str, client_name: str) -> None:
        """
        Add a new API key (runtime).
        
        Args:
            api_key: The API key to add
            client_name: Name of the client
        """
        self.valid_keys[api_key] = client_name
        logger.info(f"API key added for client: {client_name}")
    
    def revoke_key(self, api_key: str) -> None:
        """
        Revoke an API key (runtime).
        
        Args:
            api_key: The API key to revoke
        """
        if api_key in self.valid_keys:
            del self.valid_keys[api_key]
            logger.info(f"API key revoked")
        else:
            logger.warning(f"Attempted to revoke non-existent key")


# Global API key manager instance
api_key_manager = APIKeyManager()

# Security scheme
security = HTTPBearer()


async def verify_api_key(credentials: HTTPAuthorizationCredentials = Depends(security)) -> str:
    """
    Verify API key from request.
    
    Args:
        credentials: HTTP bearer credentials
    
    Returns:
        Client name associated with the key
    
    Raises:
        HTTPException: If authentication fails
    """
    try:
        client = api_key_manager.validate_key(credentials.credentials)
        return client
    except AuthenticationError as e:
        logger.warning(f"Authentication failed: {e.message}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=e.message,
            headers={"WWW-Authenticate": "Bearer"},
        )


async def get_current_client(client: str = Depends(verify_api_key)) -> str:
    """
    Get current authenticated client.
    
    Args:
        client: Client name from API key verification
    
    Returns:
        Client name
    """
    return client
