"""Model validation and health checking"""

import os
import pickle
from typing import Any, Dict, Optional, Tuple
from app.core.exceptions import ModelError
from app.core.logging import logger


class ModelValidator:
    """Validates model predictions and health"""
    
    def __init__(self, confidence_threshold: float = 0.3):
        """
        Initialize model validator.
        
        Args:
            confidence_threshold: Minimum confidence score for valid predictions
        """
        self.confidence_threshold = confidence_threshold
    
    def validate_model_files(self, model_path: str, encoder_path: str) -> None:
        """
        Validate that model files exist and are readable.
        
        Args:
            model_path: Path to model pickle file
            encoder_path: Path to encoders pickle file
        
        Raises:
            ModelError: If files don't exist or can't be read
        """
        if not os.path.exists(model_path):
            raise ModelError(
                f"Model file not found at {model_path}",
                details={"model_path": model_path}
            )
        
        if not os.path.exists(encoder_path):
            raise ModelError(
                f"Encoder file not found at {encoder_path}",
                details={"encoder_path": encoder_path}
            )
        
        # Try to load files to verify they're valid pickle files
        try:
            with open(model_path, 'rb') as f:
                pickle.load(f)
            logger.info(f"Model file validated: {model_path}")
        except Exception as e:
            raise ModelError(
                f"Failed to load model file: {str(e)}",
                details={"model_path": model_path, "error": str(e)}
            )
        
        try:
            with open(encoder_path, 'rb') as f:
                encoders = pickle.load(f)
            
            # Verify required encoders exist
            required_encoders = ['province', 'district', 'season', 'slope', 'seeds', 'crop']
            missing_encoders = [enc for enc in required_encoders if enc not in encoders]
            
            if missing_encoders:
                raise ModelError(
                    f"Missing required encoders: {', '.join(missing_encoders)}",
                    details={"missing_encoders": missing_encoders}
                )
            
            logger.info(f"Encoder file validated: {encoder_path}")
        except Exception as e:
            raise ModelError(
                f"Failed to load encoder file: {str(e)}",
                details={"encoder_path": encoder_path, "error": str(e)}
            )
    
    def validate_prediction_confidence(
        self,
        prediction: str,
        confidence_score: Optional[float] = None
    ) -> Tuple[bool, Optional[str]]:
        """
        Validate prediction confidence.
        
        Args:
            prediction: The predicted crop
            confidence_score: Confidence score of the prediction (0.0 to 1.0)
        
        Returns:
            Tuple of (is_valid, disclaimer_message)
        """
        if confidence_score is None:
            # If no confidence score provided, assume valid
            return True, None
        
        if confidence_score < self.confidence_threshold:
            disclaimer = (
                f"This recommendation has low confidence ({confidence_score:.1%}). "
                "Please consult with local agricultural experts before making decisions."
            )
            logger.warning(
                f"Low confidence prediction: {prediction} ({confidence_score:.1%})",
                extra={"prediction": prediction, "confidence": confidence_score}
            )
            return False, disclaimer
        
        return True, None
    
    def validate_input_features(
        self,
        features: Dict[str, Any],
        feature_ranges: Optional[Dict[str, Tuple[float, float]]] = None
    ) -> None:
        """
        Validate that input features are within expected ranges.
        
        Args:
            features: Dictionary of input features
            feature_ranges: Dictionary of (min, max) ranges for each feature
        
        Raises:
            ModelError: If features are out of range
        """
        if feature_ranges is None:
            return
        
        for feature_name, (min_val, max_val) in feature_ranges.items():
            if feature_name not in features:
                continue
            
            value = features[feature_name]
            if isinstance(value, (int, float)):
                if value < min_val or value > max_val:
                    raise ModelError(
                        f"Feature '{feature_name}' value {value} is outside expected range [{min_val}, {max_val}]",
                        details={
                            "feature": feature_name,
                            "value": value,
                            "min": min_val,
                            "max": max_val
                        }
                    )
    
    def get_model_health_status(self) -> Dict[str, Any]:
        """
        Get current model health status.
        
        Returns:
            Dictionary with model health information
        """
        return {
            "status": "healthy",
            "confidence_threshold": self.confidence_threshold,
            "timestamp": None  # Will be set by caller
        }
