"""Tests for input validation functions"""

import pytest
from app.core.validators import (
    validate_string_field,
    validate_integer_field,
    validate_prediction_request,
    _contains_sql_injection_pattern,
    _contains_script_tags
)
from app.core.exceptions import ValidationError


class TestValidateStringField:
    """Tests for string field validation"""
    
    def test_valid_string(self):
        """Test validation with valid string"""
        result = validate_string_field("Gasabo", "district")
        assert result == "Gasabo"
    
    def test_empty_string(self):
        """Test validation with empty string"""
        with pytest.raises(ValidationError) as exc_info:
            validate_string_field("", "district")
        assert exc_info.value.error_code == "VALIDATION_ERROR"
    
    def test_string_exceeds_max_length(self):
        """Test validation with string exceeding max length"""
        with pytest.raises(ValidationError) as exc_info:
            validate_string_field("x" * 101, "district", max_length=100)
        assert exc_info.value.error_code == "VALIDATION_ERROR"
    
    def test_non_string_type(self):
        """Test validation with non-string type"""
        with pytest.raises(ValidationError) as exc_info:
            validate_string_field(123, "district")
        assert exc_info.value.error_code == "VALIDATION_ERROR"
    
    def test_enum_validation_valid(self):
        """Test enum validation with valid value"""
        result = validate_string_field(
            "Gasabo",
            "district",
            allowed_values=["Gasabo", "Kicukiro", "Nyarugenge"]
        )
        assert result == "Gasabo"
    
    def test_enum_validation_invalid(self):
        """Test enum validation with invalid value"""
        with pytest.raises(ValidationError) as exc_info:
            validate_string_field(
                "InvalidDistrict",
                "district",
                allowed_values=["Gasabo", "Kicukiro", "Nyarugenge"]
            )
        assert exc_info.value.error_code == "VALIDATION_ERROR"
    
    def test_sql_injection_detection(self):
        """Test SQL injection pattern detection"""
        with pytest.raises(ValidationError):
            validate_string_field(
                "Gasabo'; DROP TABLE predictions; --",
                "district"
            )
    
    def test_script_tag_detection(self):
        """Test script tag detection"""
        with pytest.raises(ValidationError):
            validate_string_field(
                "<script>alert('xss')</script>",
                "district"
            )


class TestValidateIntegerField:
    """Tests for integer field validation"""
    
    def test_valid_integer(self):
        """Test validation with valid integer"""
        result = validate_integer_field(1, "inorganic_fert", min_value=0, max_value=1)
        assert result == 1
    
    def test_non_integer_type(self):
        """Test validation with non-integer type"""
        with pytest.raises(ValidationError) as exc_info:
            validate_integer_field("1", "inorganic_fert")
        assert exc_info.value.error_code == "VALIDATION_ERROR"
    
    def test_value_below_minimum(self):
        """Test validation with value below minimum"""
        with pytest.raises(ValidationError) as exc_info:
            validate_integer_field(-1, "inorganic_fert", min_value=0, max_value=1)
        assert exc_info.value.error_code == "VALIDATION_ERROR"
    
    def test_value_above_maximum(self):
        """Test validation with value above maximum"""
        with pytest.raises(ValidationError) as exc_info:
            validate_integer_field(2, "inorganic_fert", min_value=0, max_value=1)
        assert exc_info.value.error_code == "VALIDATION_ERROR"
    
    def test_boundary_values(self):
        """Test validation with boundary values"""
        assert validate_integer_field(0, "inorganic_fert", min_value=0, max_value=1) == 0
        assert validate_integer_field(1, "inorganic_fert", min_value=0, max_value=1) == 1


class TestValidatePredictionRequest:
    """Tests for complete prediction request validation"""
    
    def test_valid_request(self, valid_prediction_request):
        """Test validation with valid request"""
        allowed_values = {
            "provinces": ["Kigali"],
            "districts": ["Gasabo"],
            "seasons": ["Season A"],
            "slopes": ["Yes", "No"],
            "seeds": ["Improved seeds", "Traditional seeds"]
        }
        result = validate_prediction_request(valid_prediction_request, allowed_values)
        assert result["province"] == "Kigali"
        assert result["district"] == "Gasabo"
    
    def test_missing_required_field(self):
        """Test validation with missing required field"""
        request = {
            "province": "Kigali",
            "district": "Gasabo",
            # Missing other fields
        }
        allowed_values = {
            "provinces": ["Kigali"],
            "districts": ["Gasabo"],
            "seasons": ["Season A"],
            "slopes": ["Yes", "No"],
            "seeds": ["Improved seeds"]
        }
        with pytest.raises(ValidationError) as exc_info:
            validate_prediction_request(request, allowed_values)
        assert "missing" in exc_info.value.message.lower()
    
    def test_unexpected_fields(self):
        """Test validation with unexpected fields"""
        request = {
            "province": "Kigali",
            "district": "Gasabo",
            "season": "Season A",
            "slope": "No",
            "seeds": "Improved seeds",
            "inorganic_fert": 1,
            "organic_fert": 0,
            "used_lime": 0,
            "extra_field": "should not be here"
        }
        allowed_values = {
            "provinces": ["Kigali"],
            "districts": ["Gasabo"],
            "seasons": ["Season A"],
            "slopes": ["Yes", "No"],
            "seeds": ["Improved seeds"]
        }
        with pytest.raises(ValidationError) as exc_info:
            validate_prediction_request(request, allowed_values)
        assert "unexpected" in exc_info.value.message.lower()
    
    def test_invalid_enum_value(self):
        """Test validation with invalid enum value"""
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
        allowed_values = {
            "provinces": ["Kigali"],
            "districts": ["Gasabo"],
            "seasons": ["Season A"],
            "slopes": ["Yes", "No"],
            "seeds": ["Improved seeds"]
        }
        with pytest.raises(ValidationError) as exc_info:
            validate_prediction_request(request, allowed_values)
        assert "must be one of" in exc_info.value.message.lower()


class TestSQLInjectionDetection:
    """Tests for SQL injection pattern detection"""
    
    def test_union_select_pattern(self):
        """Test detection of UNION SELECT pattern"""
        assert _contains_sql_injection_pattern("' UNION SELECT * FROM users --")
    
    def test_drop_table_pattern(self):
        """Test detection of DROP TABLE pattern"""
        assert _contains_sql_injection_pattern("'; DROP TABLE predictions; --")
    
    def test_insert_pattern(self):
        """Test detection of INSERT pattern"""
        assert _contains_sql_injection_pattern("' INSERT INTO users VALUES ('admin') --")
    
    def test_comment_pattern(self):
        """Test detection of comment pattern"""
        assert _contains_sql_injection_pattern("' -- comment")
    
    def test_no_injection(self):
        """Test that normal strings don't trigger detection"""
        assert not _contains_sql_injection_pattern("Gasabo")
        assert not _contains_sql_injection_pattern("Improved seeds")


class TestXSSDetection:
    """Tests for XSS/script tag detection"""
    
    def test_script_tag(self):
        """Test detection of script tag"""
        assert _contains_script_tags("<script>alert('xss')</script>")
    
    def test_iframe_tag(self):
        """Test detection of iframe tag"""
        assert _contains_script_tags("<iframe src='evil.com'></iframe>")
    
    def test_javascript_protocol(self):
        """Test detection of javascript: protocol"""
        assert _contains_script_tags("javascript:alert('xss')")
    
    def test_event_handler(self):
        """Test detection of event handler"""
        assert _contains_script_tags("onclick=alert('xss')")
    
    def test_no_xss(self):
        """Test that normal strings don't trigger detection"""
        assert not _contains_script_tags("Gasabo")
        assert not _contains_script_tags("Improved seeds")
