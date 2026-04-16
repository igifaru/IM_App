"""Input validation functions for prediction requests"""

import re
from typing import Any, Dict, List, Optional
from app.core.exceptions import ValidationError


# Maximum string lengths for security
MAX_STRING_LENGTH = 100
MAX_REQUEST_SIZE_BYTES = 10 * 1024  # 10 KB


def validate_string_field(
    value: str,
    field_name: str,
    max_length: int = MAX_STRING_LENGTH,
    allowed_values: Optional[List[str]] = None
) -> str:
    """
    Validate a string field.
    
    Args:
        value: The value to validate
        field_name: Name of the field for error messages
        max_length: Maximum allowed string length
        allowed_values: List of allowed values (enum validation)
    
    Returns:
        The validated value
    
    Raises:
        ValidationError: If validation fails
    """
    if not isinstance(value, str):
        raise ValidationError(
            f"Field '{field_name}' must be a string",
            details={"field": field_name, "expected_type": "string", "received_type": type(value).__name__}
        )
    
    if len(value) == 0:
        raise ValidationError(
            f"Field '{field_name}' cannot be empty",
            details={"field": field_name}
        )
    
    if len(value) > max_length:
        raise ValidationError(
            f"Field '{field_name}' exceeds maximum length of {max_length} characters",
            details={"field": field_name, "max_length": max_length, "actual_length": len(value)}
        )
    
    # Check for SQL injection patterns
    if _contains_sql_injection_pattern(value):
        raise ValidationError(
            f"Field '{field_name}' contains invalid characters",
            details={"field": field_name}
        )
    
    # Check for script tags
    if _contains_script_tags(value):
        raise ValidationError(
            f"Field '{field_name}' contains invalid characters",
            details={"field": field_name}
        )
    
    # Enum validation
    if allowed_values and value not in allowed_values:
        raise ValidationError(
            f"Field '{field_name}' must be one of: {', '.join(allowed_values)}",
            details={"field": field_name, "allowed_values": allowed_values, "received_value": value}
        )
    
    return value


def validate_integer_field(
    value: Any,
    field_name: str,
    min_value: int = 0,
    max_value: int = 1
) -> int:
    """
    Validate an integer field.
    
    Args:
        value: The value to validate
        field_name: Name of the field for error messages
        min_value: Minimum allowed value
        max_value: Maximum allowed value
    
    Returns:
        The validated value
    
    Raises:
        ValidationError: If validation fails
    """
    if not isinstance(value, int):
        raise ValidationError(
            f"Field '{field_name}' must be an integer",
            details={"field": field_name, "expected_type": "integer", "received_type": type(value).__name__}
        )
    
    if value < min_value or value > max_value:
        raise ValidationError(
            f"Field '{field_name}' must be between {min_value} and {max_value}",
            details={"field": field_name, "min_value": min_value, "max_value": max_value, "received_value": value}
        )
    
    return value


def validate_prediction_request(
    data: Dict[str, Any],
    allowed_values: Dict[str, List[str]]
) -> Dict[str, Any]:
    """
    Validate a complete prediction request.
    
    Args:
        data: The request data to validate
        allowed_values: Dictionary of allowed values for each categorical field
    
    Returns:
        The validated data
    
    Raises:
        ValidationError: If validation fails
    """
    required_fields = ["province", "district", "season", "slope", "seeds", "inorganic_fert", "organic_fert", "used_lime"]
    
    # Check for required fields
    for field in required_fields:
        if field not in data:
            raise ValidationError(
                f"Missing required field: '{field}'",
                details={"missing_field": field, "required_fields": required_fields}
            )
    
    # Check for unexpected fields (allow crop as optional)
    allowed_fields = set(required_fields + ["crop"])
    received_fields = set(data.keys())
    unexpected_fields = received_fields - allowed_fields
    if unexpected_fields:
        raise ValidationError(
            f"Unexpected fields: {', '.join(unexpected_fields)}",
            details={"unexpected_fields": list(unexpected_fields)}
        )
    
    # Validate string fields
    validated_data = {}
    validated_data["province"] = validate_string_field(
        data["province"],
        "province",
        allowed_values=allowed_values.get("provinces", [])
    )
    validated_data["district"] = validate_string_field(
        data["district"],
        "district",
        allowed_values=allowed_values.get("districts", [])
    )
    validated_data["season"] = validate_string_field(
        data["season"],
        "season",
        allowed_values=allowed_values.get("seasons", [])
    )
    validated_data["slope"] = validate_string_field(
        data["slope"],
        "slope",
        allowed_values=allowed_values.get("slopes", [])
    )
    validated_data["seeds"] = validate_string_field(
        data["seeds"],
        "seeds",
        allowed_values=allowed_values.get("seeds", [])
    )
    
    # Validate integer fields (0 or 1)
    validated_data["inorganic_fert"] = validate_integer_field(
        data["inorganic_fert"],
        "inorganic_fert",
        min_value=0,
        max_value=1
    )
    validated_data["organic_fert"] = validate_integer_field(
        data["organic_fert"],
        "organic_fert",
        min_value=0,
        max_value=1
    )
    validated_data["used_lime"] = validate_integer_field(
        data["used_lime"],
        "used_lime",
        min_value=0,
        max_value=1
    )
    
    # Validate crop if provided (optional for regular predict, required for smart consultant)
    if "crop" in data and data["crop"] is not None:
        validated_data["crop"] = validate_string_field(
            data["crop"],
            "crop",
            allowed_values=allowed_values.get("crops", [])
        )
    
    return validated_data


def _contains_sql_injection_pattern(value: str) -> bool:
    """Check if value contains SQL injection patterns"""
    sql_patterns = [
        r"(\b(UNION|SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|EXECUTE)\b)",
        r"(--|;|'|\")",
        r"(\*|%)",
    ]
    
    for pattern in sql_patterns:
        if re.search(pattern, value, re.IGNORECASE):
            return True
    return False


def _contains_script_tags(value: str) -> bool:
    """Check if value contains script tags or HTML"""
    script_patterns = [
        r"<script[^>]*>.*?</script>",
        r"<iframe[^>]*>.*?</iframe>",
        r"javascript:",
        r"on\w+\s*=",
    ]
    
    for pattern in script_patterns:
        if re.search(pattern, value, re.IGNORECASE):
            return True
    return False
