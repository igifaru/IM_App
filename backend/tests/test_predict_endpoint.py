"""Tests for prediction API endpoints"""

import pytest
from fastapi.testclient import TestClient
from app.main import app


@pytest.fixture
def client():
    """FastAPI test client"""
    return TestClient(app)


class TestPredictEndpoint:
    """Tests for /predict endpoint"""
    
    def test_predict_valid_request(self, client, valid_prediction_request):
        """Test prediction with valid request"""
        response = client.post("/api/v1/predict", json=valid_prediction_request)
        assert response.status_code == 200
        data = response.json()
        assert "recommended_crop" in data
        assert "status" in data
        assert "advice" in data
        assert "confidence_score" in data
        assert "timestamp" in data
    
    def test_predict_returns_confidence_score(self, client, valid_prediction_request):
        """Test that prediction includes confidence score"""
        response = client.post("/api/v1/predict", json=valid_prediction_request)
        assert response.status_code == 200
        data = response.json()
        assert data["confidence_score"] is not None
        assert 0.0 <= data["confidence_score"] <= 1.0
    
    def test_predict_low_confidence_flag(self, client, valid_prediction_request):
        """Test low confidence flag in response"""
        response = client.post("/api/v1/predict", json=valid_prediction_request)
        assert response.status_code == 200
        data = response.json()
        assert "low_confidence" in data
        assert isinstance(data["low_confidence"], bool)
    
    def test_predict_missing_required_field(self, client):
        """Test prediction with missing required field"""
        request = {
            "province": "Kigali",
            "district": "Gasabo",
            # Missing other fields
        }
        response = client.post("/api/v1/predict", json=request)
        assert response.status_code == 422  # Validation error
    
    def test_predict_invalid_data_type(self, client):
        """Test prediction with invalid data type"""
        request = {
            "province": "Kigali",
            "district": "Gasabo",
            "season": "Season A",
            "slope": "No",
            "seeds": "Improved seeds",
            "inorganic_fert": "yes",  # Should be int
            "organic_fert": 0,
            "used_lime": 0
        }
        response = client.post("/api/v1/predict", json=request)
        assert response.status_code == 422  # Validation error
    
    def test_predict_out_of_range_value(self, client):
        """Test prediction with out-of-range value"""
        request = {
            "province": "Kigali",
            "district": "Gasabo",
            "season": "Season A",
            "slope": "No",
            "seeds": "Improved seeds",
            "inorganic_fert": 2,  # Should be 0 or 1
            "organic_fert": 0,
            "used_lime": 0
        }
        response = client.post("/api/v1/predict", json=request)
        assert response.status_code == 422  # Validation error
    
    def test_predict_sql_injection_attempt(self, client):
        """Test prediction with SQL injection attempt"""
        request = {
            "province": "Kigali",
            "district": "Gasabo'; DROP TABLE predictions; --",
            "season": "Season A",
            "slope": "No",
            "seeds": "Improved seeds",
            "inorganic_fert": 1,
            "organic_fert": 0,
            "used_lime": 0
        }
        response = client.post("/api/v1/predict", json=request)
        assert response.status_code == 400  # Validation error
        data = response.json()
        assert data["error_code"] == "VALIDATION_ERROR"
    
    def test_predict_xss_attempt(self, client):
        """Test prediction with XSS attempt"""
        request = {
            "province": "Kigali",
            "district": "<script>alert('xss')</script>",
            "season": "Season A",
            "slope": "No",
            "seeds": "Improved seeds",
            "inorganic_fert": 1,
            "organic_fert": 0,
            "used_lime": 0
        }
        response = client.post("/api/v1/predict", json=request)
        assert response.status_code == 400  # Validation error
        data = response.json()
        assert data["error_code"] == "VALIDATION_ERROR"
    
    def test_predict_language_parameter(self, client, valid_prediction_request):
        """Test prediction with different language parameter"""
        for lang in ["en", "fr", "rw"]:
            response = client.post(
                f"/api/v1/predict?lang={lang}",
                json=valid_prediction_request
            )
            assert response.status_code == 200
            data = response.json()
            assert "advice" in data
    
    def test_predict_response_includes_request_id(self, client, valid_prediction_request):
        """Test that response includes request ID header"""
        response = client.post("/api/v1/predict", json=valid_prediction_request)
        assert response.status_code == 200
        assert "X-Request-ID" in response.headers


class TestMetadataEndpoint:
    """Tests for /metadata endpoint"""
    
    def test_metadata_returns_all_fields(self, client):
        """Test that metadata includes all required fields"""
        response = client.get("/api/v1/metadata")
        assert response.status_code == 200
        data = response.json()
        assert "provinces" in data
        assert "districts" in data
        assert "seasons" in data
        assert "slopes" in data
        assert "seeds" in data
        assert "crops" in data
    
    def test_metadata_returns_lists(self, client):
        """Test that metadata fields are lists"""
        response = client.get("/api/v1/metadata")
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data["provinces"], list)
        assert isinstance(data["districts"], list)
        assert isinstance(data["seasons"], list)
        assert isinstance(data["slopes"], list)
        assert isinstance(data["seeds"], list)
        assert isinstance(data["crops"], list)
    
    def test_metadata_lists_not_empty(self, client):
        """Test that metadata lists are not empty"""
        response = client.get("/api/v1/metadata")
        assert response.status_code == 200
        data = response.json()
        assert len(data["provinces"]) > 0
        assert len(data["districts"]) > 0
        assert len(data["seasons"]) > 0
        assert len(data["slopes"]) > 0
        assert len(data["seeds"]) > 0
        assert len(data["crops"]) > 0
    
    def test_metadata_response_includes_request_id(self, client):
        """Test that response includes request ID header"""
        response = client.get("/api/v1/metadata")
        assert response.status_code == 200
        assert "X-Request-ID" in response.headers


class TestHealthEndpoint:
    """Tests for /health endpoint"""
    
    def test_health_check_returns_healthy(self, client):
        """Test that health check returns healthy status"""
        response = client.get("/api/v1/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
    
    def test_health_check_includes_timestamp(self, client):
        """Test that health check includes timestamp"""
        response = client.get("/api/v1/health")
        assert response.status_code == 200
        data = response.json()
        assert "timestamp" in data
    
    def test_health_check_includes_components(self, client):
        """Test that health check includes component status"""
        response = client.get("/api/v1/health")
        assert response.status_code == 200
        data = response.json()
        assert "components" in data
        assert "model_service" in data["components"]
    
    def test_readiness_check_returns_ready(self, client):
        """Test that readiness check returns ready status"""
        response = client.get("/api/v1/health/ready")
        assert response.status_code == 200
        data = response.json()
        assert data["ready"] is True
    
    def test_liveness_check_returns_alive(self, client):
        """Test that liveness check returns alive status"""
        response = client.get("/api/v1/health/live")
        assert response.status_code == 200
        data = response.json()
        assert data["alive"] is True


class TestErrorHandling:
    """Tests for error handling"""
    
    def test_validation_error_includes_reference_id(self, client):
        """Test that validation errors include reference ID"""
        request = {
            "province": "Kigali",
            "district": "InvalidDistrict",
            "season": "Season A",
            "slope": "No",
            "seeds": "Improved seeds",
            "inorganic_fert": 1,
            "organic_fert": 0,
            "used_lime": 0
        }
        response = client.post("/api/v1/predict", json=request)
        assert response.status_code == 400
        data = response.json()
        assert "reference_id" in data
        assert data["reference_id"] is not None
    
    def test_validation_error_includes_error_code(self, client):
        """Test that validation errors include error code"""
        request = {
            "province": "Kigali",
            "district": "InvalidDistrict",
            "season": "Season A",
            "slope": "No",
            "seeds": "Improved seeds",
            "inorganic_fert": 1,
            "organic_fert": 0,
            "used_lime": 0
        }
        response = client.post("/api/v1/predict", json=request)
        assert response.status_code == 400
        data = response.json()
        assert "error_code" in data
        assert data["error_code"] == "VALIDATION_ERROR"
    
    def test_validation_error_includes_message(self, client):
        """Test that validation errors include user-friendly message"""
        request = {
            "province": "Kigali",
            "district": "InvalidDistrict",
            "season": "Season A",
            "slope": "No",
            "seeds": "Improved seeds",
            "inorganic_fert": 1,
            "organic_fert": 0,
            "used_lime": 0
        }
        response = client.post("/api/v1/predict", json=request)
        assert response.status_code == 400
        data = response.json()
        assert "message" in data
        assert len(data["message"]) > 0
    
    def test_validation_error_includes_details(self, client):
        """Test that validation errors include details"""
        request = {
            "province": "Kigali",
            "district": "InvalidDistrict",
            "season": "Season A",
            "slope": "No",
            "seeds": "Improved seeds",
            "inorganic_fert": 1,
            "organic_fert": 0,
            "used_lime": 0
        }
        response = client.post("/api/v1/predict", json=request)
        assert response.status_code == 400
        data = response.json()
        assert "details" in data
