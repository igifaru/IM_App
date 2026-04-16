"""Pytest configuration and fixtures"""

import pytest
from fastapi.testclient import TestClient
from app.main import app


@pytest.fixture
def client():
    """FastAPI test client"""
    return TestClient(app)


@pytest.fixture
def valid_prediction_request():
    """Valid prediction request data"""
    return {
        "province": "Kigali",
        "district": "Gasabo",
        "season": "Season A",
        "slope": "No",
        "seeds": "Improved seeds",
        "inorganic_fert": 1,
        "organic_fert": 0,
        "used_lime": 0
    }


@pytest.fixture
def invalid_prediction_requests():
    """Collection of invalid prediction requests"""
    return [
        # Missing required field
        {
            "province": "Kigali",
            "district": "Gasabo",
            "season": "Season A",
            # Missing slope, seeds, etc.
        },
        # Invalid data type
        {
            "province": "Kigali",
            "district": "Gasabo",
            "season": "Season A",
            "slope": "No",
            "seeds": "Improved seeds",
            "inorganic_fert": "yes",  # Should be int
            "organic_fert": 0,
            "used_lime": 0
        },
        # Out of range value
        {
            "province": "Kigali",
            "district": "Gasabo",
            "season": "Season A",
            "slope": "No",
            "seeds": "Improved seeds",
            "inorganic_fert": 2,  # Should be 0 or 1
            "organic_fert": 0,
            "used_lime": 0
        },
        # Invalid enum value
        {
            "province": "Kigali",
            "district": "InvalidDistrict",  # Not in allowed values
            "season": "Season A",
            "slope": "No",
            "seeds": "Improved seeds",
            "inorganic_fert": 1,
            "organic_fert": 0,
            "used_lime": 0
        },
        # SQL injection attempt
        {
            "province": "Kigali",
            "district": "Gasabo'; DROP TABLE predictions; --",
            "season": "Season A",
            "slope": "No",
            "seeds": "Improved seeds",
            "inorganic_fert": 1,
            "organic_fert": 0,
            "used_lime": 0
        },
        # XSS attempt
        {
            "province": "Kigali",
            "district": "<script>alert('xss')</script>",
            "season": "Season A",
            "slope": "No",
            "seeds": "Improved seeds",
            "inorganic_fert": 1,
            "organic_fert": 0,
            "used_lime": 0
        }
    ]
