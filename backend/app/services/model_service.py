"""ML Model service for crop predictions"""

import pickle
import pandas as pd
import os
import numpy as np
from typing import Dict, Any, Tuple, Optional, List
from dataclasses import dataclass
from app.core.exceptions import ModelError
from app.core.logging import logger
from app.core.config import settings


@dataclass
class CropScore:
    """Represents a crop with its confidence score and rank"""
    crop: str
    confidence: float
    rank: int = 0


@dataclass
class CropValidation:
    """Represents validation result for farmer's crop choice"""
    crop: str
    confidence: float
    status: str  # "good", "moderate", "poor"
    color: str  # "green", "yellow", "red"
    message: str


class ModelService:
    """Service for loading and using the ML model for predictions"""
    
    def __init__(self, model_path: str, encoders_path: str):
        """
        Initialize model service.
        
        Args:
            model_path: Path to trained model pickle file
            encoders_path: Path to label encoders pickle file
        
        Raises:
            ModelError: If model files cannot be loaded
        """
        self.model_path = model_path
        self.encoders_path = encoders_path
        self.model = None
        self.encoders = None
        self.metadata = None
        self._load_models()
    
    def _load_models(self) -> None:
        """
        Load model and encoders from pickle files.
        
        Raises:
            ModelError: If files don't exist or can't be loaded
        """
        if not os.path.exists(self.model_path):
            raise ModelError(
                f"Model file not found at {self.model_path}",
                details={"model_path": self.model_path}
            )
        if not os.path.exists(self.encoders_path):
            raise ModelError(
                f"Encoder file not found at {self.encoders_path}",
                details={"encoder_path": self.encoders_path}
            )
        
        try:
            with open(self.model_path, 'rb') as f:
                self.model = pickle.load(f)
            logger.info(f"Model loaded successfully from {self.model_path}")
        except Exception as e:
            raise ModelError(
                f"Failed to load model: {str(e)}",
                details={"model_path": self.model_path, "error": str(e)}
            )
        
        try:
            with open(self.encoders_path, 'rb') as f:
                self.encoders = pickle.load(f)
            logger.info(f"Encoders loaded successfully from {self.encoders_path}")
        except Exception as e:
            raise ModelError(
                f"Failed to load encoders: {str(e)}",
                details={"encoder_path": self.encoders_path, "error": str(e)}
            )
        
        # Cache metadata
        self._cache_metadata()
    
    def _cache_metadata(self) -> None:
        """Cache metadata from encoders for faster access"""
        try:
            self.metadata = {
                'provinces': list(self.encoders['province'].classes_),
                'districts': list(self.encoders['district'].classes_),
                'seasons': list(self.encoders['season'].classes_),
                'slopes': list(self.encoders['slope'].classes_),
                'seeds': list(self.encoders['seeds'].classes_),
                'crops': list(self.encoders['crop'].classes_)
            }
            logger.debug(f"Metadata cached: {len(self.metadata['crops'])} crops available")
        except Exception as e:
            logger.error(f"Failed to cache metadata: {str(e)}", exc_info=True)
            self.metadata = None
    
    def predict(self, data: Dict[str, Any]) -> Tuple[str, Optional[float]]:
        """
        Make a crop prediction based on input features.
        
        Args:
            data: Dictionary with prediction input features
        
        Returns:
            Tuple of (recommended_crop, confidence_score)
        
        Raises:
            ModelError: If prediction fails
        """
        try:
            # Transform inputs using encoders
            p_enc = self.encoders['province'].transform([data['province']])
            d_enc = self.encoders['district'].transform([data['district']])
            s_enc = self.encoders['season'].transform([data['season']])
            sl_enc = self.encoders['slope'].transform([data['slope']])
            sd_enc = self.encoders['seeds'].transform([data['seeds']])
            
            # Prepare features in the exact order trained
            # ['Province_Enc', 'District_Enc', 'Season_Enc', 'Slope_Enc', 'Seeds_Enc', 'Inorganic_Fert', 'Organic_Fert', 'Used_Lime']
            feature_names = [
                'Province_Enc', 'District_Enc', 'Season_Enc', 'Slope_Enc', 'Seeds_Enc',
                'Inorganic_Fert', 'Organic_Fert', 'Used_Lime'
            ]
            input_df = pd.DataFrame([[
                p_enc[0], d_enc[0], s_enc[0], sl_enc[0], sd_enc[0],
                data['inorganic_fert'], data['organic_fert'], data['used_lime']
            ]], columns=feature_names)
            
            # Predict
            crop_id = self.model.predict(input_df)
            recommended_crop = self.encoders['crop'].inverse_transform(crop_id)[0]
            
            # Try to get confidence score if model supports it
            confidence_score = None
            try:
                if hasattr(self.model, 'predict_proba'):
                    probabilities = self.model.predict_proba(input_df)
                    confidence_score = float(probabilities[0].max())
            except Exception as e:
                logger.debug(f"Could not get confidence score: {str(e)}")
            
            logger.info(
                f"Prediction made: {recommended_crop}",
                extra={
                    "crop": recommended_crop,
                    "confidence": confidence_score,
                    "inputs": {k: v for k, v in data.items() if k not in ['province', 'district']}
                }
            )
            
            return recommended_crop, confidence_score
        
        except Exception as e:
            logger.error(f"Prediction failed: {str(e)}", exc_info=True)
            raise ModelError(
                f"Prediction failed: {str(e)}",
                details={"error": str(e)}
            )
    
    def get_metadata(self) -> Dict[str, list]:
        """
        Get metadata about available options.
        
        Returns:
            Dictionary with lists of provinces, districts, seasons, slopes, seeds, crops
        """
        if self.metadata is None:
            self._cache_metadata()
        
        return self.metadata or {
            'provinces': [],
            'districts': [],
            'seasons': [],
            'slopes': [],
            'seeds': [],
            'crops': []
        }
    
    def is_healthy(self) -> bool:
        """
        Check if model service is healthy.
        
        Returns:
            True if model and encoders are loaded
        """
        return self.model is not None and self.encoders is not None
    
    def score_all_crops(self, farm_data: Dict[str, Any]) -> List[CropScore]:
        """
        Score all available crops for given farm conditions.
        
        Args:
            farm_data: Dictionary with farm conditions (province, district, season, etc.)
        
        Returns:
            List of CropScore objects sorted by confidence (highest first)
        
        Raises:
            ModelError: If scoring fails
        """
        try:
            all_crops = self.metadata['crops']
            scores = []
            
            # Transform common features once
            p_enc = self.encoders['province'].transform([farm_data['province']])[0]
            d_enc = self.encoders['district'].transform([farm_data['district']])[0]
            s_enc = self.encoders['season'].transform([farm_data['season']])[0]
            sl_enc = self.encoders['slope'].transform([farm_data['slope']])[0]
            sd_enc = self.encoders['seeds'].transform([farm_data['seeds']])[0]
            
            # Score each crop
            for crop in all_crops:
                try:
                    # Encode crop
                    crop_enc = self.encoders['crop'].transform([crop])[0]
                    
                    # Prepare features
                    feature_names = [
                        'Province_Enc', 'District_Enc', 'Season_Enc', 'Slope_Enc', 'Seeds_Enc',
                        'Inorganic_Fert', 'Organic_Fert', 'Used_Lime'
                    ]
                    input_df = pd.DataFrame([[
                        p_enc, d_enc, s_enc, sl_enc, sd_enc,
                        farm_data['inorganic_fert'],
                        farm_data['organic_fert'],
                        farm_data['used_lime']
                    ]], columns=feature_names)
                    
                    # Get confidence score
                    confidence = 0.5  # Default
                    if hasattr(self.model, 'predict_proba'):
                        # Get probability for this specific crop
                        probabilities = self.model.predict_proba(input_df)[0]
                        # Find the probability for this crop's class
                        crop_class_idx = np.where(self.model.classes_ == crop_enc)[0]
                        if len(crop_class_idx) > 0:
                            confidence = float(probabilities[crop_class_idx[0]])
                    
                    scores.append(CropScore(
                        crop=crop,
                        confidence=confidence,
                        rank=0  # Will be set after sorting
                    ))
                
                except Exception as e:
                    logger.warning(f"Failed to score crop {crop}: {str(e)}")
                    # Add with low confidence if scoring fails
                    scores.append(CropScore(crop=crop, confidence=0.1, rank=0))
            
            # Sort by confidence (highest first)
            scores.sort(key=lambda x: x.confidence, reverse=True)
            
            # Assign ranks
            for i, score in enumerate(scores):
                score.rank = i + 1
            
            logger.info(
                f"Scored {len(scores)} crops",
                extra={
                    "top_3": [f"{s.crop}:{s.confidence:.2f}" for s in scores[:3]],
                    "conditions": {
                        "province": farm_data['province'],
                        "district": farm_data['district'],
                        "season": farm_data['season']
                    }
                }
            )
            
            return scores
        
        except Exception as e:
            logger.error(f"Failed to score all crops: {str(e)}", exc_info=True)
            raise ModelError(
                f"Failed to score crops: {str(e)}",
                details={"error": str(e)}
            )
    
    def validate_crop_choice(
        self,
        selected_crop: str,
        farm_data: Dict[str, Any]
    ) -> CropValidation:
        """
        Validate farmer's crop choice against farm conditions.
        
        Args:
            selected_crop: Crop selected by farmer
            farm_data: Dictionary with farm conditions
        
        Returns:
            CropValidation with status and message
        
        Raises:
            ModelError: If validation fails
        """
        try:
            # Get all scores to find where selected crop ranks
            all_scores = self.score_all_crops(farm_data)
            
            # Find selected crop in scores
            selected_score = next(
                (s for s in all_scores if s.crop == selected_crop),
                None
            )
            
            if selected_score is None:
                raise ModelError(
                    f"Crop '{selected_crop}' not found in available crops",
                    details={"selected_crop": selected_crop}
                )
            
            confidence = selected_score.confidence
            
            # Determine status based on confidence
            if confidence >= 0.7:
                status = "good"
                color = "green"
                message = f"{selected_crop} is well-suited for your conditions"
            elif confidence >= 0.4:
                status = "moderate"
                color = "yellow"
                message = f"{selected_crop} is moderately suitable for your conditions"
            else:
                status = "poor"
                color = "red"
                message = f"Consider alternatives - {selected_crop} may face challenges in your conditions"
            
            logger.info(
                f"Validated crop choice: {selected_crop}",
                extra={
                    "crop": selected_crop,
                    "confidence": confidence,
                    "status": status,
                    "rank": selected_score.rank
                }
            )
            
            return CropValidation(
                crop=selected_crop,
                confidence=confidence,
                status=status,
                color=color,
                message=message
            )
        
        except Exception as e:
            logger.error(f"Failed to validate crop choice: {str(e)}", exc_info=True)
            raise ModelError(
                f"Failed to validate crop choice: {str(e)}",
                details={"error": str(e), "crop": selected_crop}
            )


# Singleton instance
model_service = ModelService(
    model_path=settings.MODEL_PATH,
    encoders_path=settings.ENCODER_PATH
)
