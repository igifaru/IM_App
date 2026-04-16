from typing import Any, Dict
from datetime import datetime

def format_prediction_response(prediction: str, advice: str, inputs: Dict[str, Any]) -> Dict[str, Any]:
    """
    Standardize the prediction response format.
    """
    return {
        "status": "success",
        "timestamp": datetime.now().isoformat(),
        "data": {
            "prediction": prediction,
            "advice": advice,
            "inputs": inputs
        }
    }

def handle_error(message: str, code: int = 400) -> Dict[str, Any]:
    """
    Standardize the error response format.
    """
    return {
        "status": "error",
        "error": {
            "message": message,
            "code": code
        }
    }
