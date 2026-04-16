"""Crop prediction API endpoints"""

import time
from fastapi import APIRouter, Request, status, Depends
from app.models.prediction_schema import PredictionRequest, PredictionResponse, MetadataResponse
from app.models.smart_consultant_schema import (
    SmartConsultantResponse,
    FarmerChoiceResponse,
    RecommendationResponse,
    AIInterpretationResponse,
    MetadataResponse as SmartMetadataResponse
)
from app.services.model_service import model_service
from app.services.advice_service import advice_service
from app.services.ai_interpretation_service import ai_interpretation_service
from app.core.validators import validate_prediction_request
from app.core.model_validator import ModelValidator
from app.core.exceptions import ValidationError, ModelError
from app.core.logging import logger
from app.core.config import settings
from app.core.auth import get_current_client
from app.core.rate_limiter import check_rate_limit
from datetime import datetime

router = APIRouter()
model_validator = ModelValidator(confidence_threshold=settings.CONFIDENCE_THRESHOLD)


@router.post(
    "/predict",
    response_model=PredictionResponse,
    status_code=status.HTTP_200_OK,
    responses={
        400: {"description": "Validation error"},
        401: {"description": "Unauthorized"},
        429: {"description": "Rate limit exceeded"},
        500: {"description": "Server error"}
    }
)
async def predict_crop(
    request: PredictionRequest,
    lang: str = "en",
    client: str = Depends(get_current_client),
    _: None = Depends(check_rate_limit)
) -> PredictionResponse:
    """
    Make a crop prediction based on farm characteristics.
    
    Args:
        request: Prediction request with farm details
        lang: Language for advice (en, fr, rw)
    
    Returns:
        Prediction response with recommended crop and advice
    
    Raises:
        ValidationError: If input validation fails
        ModelError: If prediction fails
    """
    start_time = time.time()
    request_id = None
    
    try:
        # Get request ID from context if available
        # (set by middleware)
        
        logger.info(
            "Prediction request received",
            extra={
                "client": client,
                "season": request.season,
                "district": request.district,
                "language": lang
            }
        )
        
        # Validate input against allowed values
        metadata = model_service.get_metadata()
        allowed_values = {
            "provinces": metadata.get('provinces', []),
            "districts": metadata.get('districts', []),
            "seasons": metadata.get('seasons', []),
            "slopes": metadata.get('slopes', []),
            "seeds": metadata.get('seeds', [])
        }
        
        # Validate prediction request
        validated_data = validate_prediction_request(
            request.dict(),
            allowed_values
        )
        
        logger.debug(
            "Input validation passed",
            extra={"validated_fields": list(validated_data.keys())}
        )
        
        # Make prediction
        recommended_crop, confidence_score = model_service.predict(validated_data)
        
        # Validate prediction confidence
        is_valid_confidence, disclaimer = model_validator.validate_prediction_confidence(
            recommended_crop,
            confidence_score
        )
        
        # Get expert advice
        advice = advice_service.get_expert_advice(
            recommended_crop,
            validated_data,
            lang
        )
        
        # Calculate response time
        duration_ms = int((time.time() - start_time) * 1000)
        
        logger.info(
            f"Prediction successful: {recommended_crop}",
            extra={
                "client": client,
                "crop": recommended_crop,
                "confidence": confidence_score,
                "duration_ms": duration_ms,
                "low_confidence": not is_valid_confidence
            }
        )
        
        # Build response
        return PredictionResponse(
            recommended_crop=recommended_crop,
            confidence_score=confidence_score,
            low_confidence=not is_valid_confidence,
            confidence_disclaimer=disclaimer,
            status="warning" if not is_valid_confidence else "success",
            advice=advice
        )
    
    except ValidationError as e:
        duration_ms = int((time.time() - start_time) * 1000)
        logger.warning(
            f"Validation error: {e.error_code}",
            extra={
                "error_code": e.error_code,
                "message": e.message,
                "duration_ms": duration_ms,
                "details": e.details
            }
        )
        raise
    
    except ModelError as e:
        duration_ms = int((time.time() - start_time) * 1000)
        logger.error(
            f"Model error: {e.error_code}",
            extra={
                "error_code": e.error_code,
                "message": e.message,
                "duration_ms": duration_ms,
                "details": e.details
            }
        )
        raise
    
    except Exception as e:
        duration_ms = int((time.time() - start_time) * 1000)
        logger.error(
            f"Unexpected error in prediction: {str(e)}",
            extra={"duration_ms": duration_ms},
            exc_info=True
        )
        raise ModelError(
            "An unexpected error occurred during prediction",
            details={"error": str(e)}
        )


@router.get(
    "/metadata",
    response_model=MetadataResponse,
    status_code=status.HTTP_200_OK,
    responses={
        401: {"description": "Unauthorized"},
        429: {"description": "Rate limit exceeded"},
        500: {"description": "Server error"}
    }
)
async def get_metadata(
    client: str = Depends(get_current_client),
    _: None = Depends(check_rate_limit)
) -> MetadataResponse:
    """
    Get metadata about available options for predictions.
    
    Returns:
        Metadata with lists of provinces, districts, seasons, slopes, seeds, and crops
    
    Raises:
        ModelError: If metadata cannot be retrieved
    """
    try:
        logger.info("Metadata request received", extra={"client": client})
        
        metadata = model_service.get_metadata()
        
        if not metadata:
            raise ModelError(
                "Failed to retrieve metadata",
                details={"reason": "Model metadata is empty"}
            )
        
        logger.info(
            "Metadata retrieved successfully",
            extra={
                "provinces_count": len(metadata.get('provinces', [])),
                "districts_count": len(metadata.get('districts', [])),
                "crops_count": len(metadata.get('crops', []))
            }
        )
        
        return MetadataResponse(**metadata)
    
    except ModelError as e:
        logger.error(
            f"Model error retrieving metadata: {e.error_code}",
            extra={"error_code": e.error_code, "message": e.message}
        )
        raise
    
    except Exception as e:
        logger.error(
            f"Unexpected error retrieving metadata: {str(e)}",
            exc_info=True
        )
        raise ModelError(
            "Failed to retrieve metadata",
            details={"error": str(e)}
        )



def _get_recommendation_reason(crop: str, farm_data: dict, confidence: float, lang: str = "en") -> str:
    """Generate detailed agronomic reason for crop recommendation based on actual farm conditions"""
    
    # Extract farm conditions
    district = farm_data.get('district', '')
    province = farm_data.get('province', '')
    season = farm_data.get('season', '')
    slope = farm_data.get('slope', '')
    seeds = farm_data.get('seeds', '')
    has_inorganic = farm_data.get('inorganic_fert', 0) == 1
    has_organic = farm_data.get('organic_fert', 0) == 1
    has_lime = farm_data.get('used_lime', 0) == 1
    
    # Build reason based on actual conditions
    reasons = {
        "en": [],
        "fr": [],
        "rw": []
    }
    
    # Confidence-based primary reason
    if confidence >= 0.7:
        reasons["en"].append(f"Excellent match ({confidence:.0%} success rate)")
        reasons["fr"].append(f"Excellente correspondance (taux de réussite {confidence:.0%})")
        reasons["rw"].append(f"Birakwiriye cyane ({confidence:.0%} yo gutsinda)")
    elif confidence >= 0.5:
        reasons["en"].append(f"Good match ({confidence:.0%} success rate)")
        reasons["fr"].append(f"Bonne correspondance (taux {confidence:.0%})")
        reasons["rw"].append(f"Birakwiriye ({confidence:.0%} yo gutsinda)")
    else:
        reasons["en"].append(f"Suitable option ({confidence:.0%} success rate)")
        reasons["fr"].append(f"Option convenable (taux {confidence:.0%})")
        reasons["rw"].append(f"Bishoboka ({confidence:.0%} yo gutsinda)")
    
    # Season-specific reasoning
    if season:
        reasons["en"].append(f"for {season} in {district}")
        reasons["fr"].append(f"pour {season} à {district}")
        reasons["rw"].append(f"muri {season} i {district}")
    
    # Fertilizer-based reasoning
    if has_inorganic and has_organic:
        reasons["en"].append("with your balanced fertilizer use")
        reasons["fr"].append("avec votre utilisation équilibrée d'engrais")
        reasons["rw"].append("hamwe n'ifumbire yawe yuzuye")
    elif has_inorganic:
        reasons["en"].append("benefits from inorganic fertilizer")
        reasons["fr"].append("bénéficie de l'engrais inorganique")
        reasons["rw"].append("ifumbire mvaruganda irafasha")
    elif has_organic:
        reasons["en"].append("thrives with organic fertilizer")
        reasons["fr"].append("prospère avec engrais organique")
        reasons["rw"].append("ifumbire y'iborera irakwiriye")
    
    # Slope-based reasoning
    if slope == "Yes":
        reasons["en"].append("suitable for sloped land")
        reasons["fr"].append("adapté aux terrains en pente")
        reasons["rw"].append("birakwiriye ubutaka buhanamye")
    
    # Seed quality reasoning
    if seeds == "Improved seeds":
        reasons["en"].append("with improved seeds")
        reasons["fr"].append("avec semences améliorées")
        reasons["rw"].append("hamwe n'imbuto nziza")
    
    # Lime usage
    if has_lime:
        reasons["en"].append("lime application helps")
        reasons["fr"].append("application de chaux aide")
        reasons["rw"].append("ishogera irafasha")
    
    # Join reasons appropriately
    if lang == "en":
        return " ".join(reasons["en"][:3])  # Limit to 3 reasons
    elif lang == "fr":
        return " ".join(reasons["fr"][:3])
    else:
        return " ".join(reasons["rw"][:3])


@router.post(
    "/smart-consultant",
    response_model=SmartConsultantResponse,
    status_code=status.HTTP_200_OK,
    responses={
        400: {"description": "Validation error"},
        401: {"description": "Unauthorized"},
        429: {"description": "Rate limit exceeded"},
        500: {"description": "Server error"}
    }
)
async def smart_consultant_predict(
    request: PredictionRequest,
    lang: str = "en",
    client: str = Depends(get_current_client),
    _: None = Depends(check_rate_limit)
) -> SmartConsultantResponse:
    """
    Smart consultant prediction with validation and recommendations.
    
    Validates farmer's crop choice, provides top 3 recommendations,
    and generates AI-powered interpretation.
    
    Args:
        request: Prediction request with farm details and crop choice
        lang: Language for interpretation (en, fr, rw)
    
    Returns:
        Smart consultant response with validation, recommendations, and AI interpretation
    
    Raises:
        ValidationError: If input validation fails or crop not provided
        ModelError: If prediction fails
    """
    start_time = time.time()
    
    try:
        # Validate that crop is provided
        if not request.crop:
            raise ValidationError(
                "Crop selection is required for smart consultant mode",
                error_code="MISSING_CROP",
                details={"field": "crop"}
            )
        
        logger.info(
            "Smart consultant request received",
            extra={
                "client": client,
                "selected_crop": request.crop,
                "district": request.district,
                "language": lang
            }
        )
        
        # Validate input against allowed values
        metadata = model_service.get_metadata()
        allowed_values = {
            "provinces": metadata.get('provinces', []),
            "districts": metadata.get('districts', []),
            "seasons": metadata.get('seasons', []),
            "slopes": metadata.get('slopes', []),
            "seeds": metadata.get('seeds', []),
            "crops": metadata.get('crops', [])
        }
        
        # Validate prediction request
        validated_data = validate_prediction_request(
            request.dict(),
            allowed_values
        )
        
        # Validate crop is in allowed list
        if request.crop not in allowed_values['crops']:
            raise ValidationError(
                f"Crop '{request.crop}' is not supported",
                error_code="INVALID_CROP",
                details={
                    "field": "crop",
                    "value": request.crop,
                    "allowed_values": allowed_values['crops']
                }
            )
        
        logger.debug("Input validation passed")
        
        # 1. Validate farmer's crop choice
        farmer_choice = model_service.validate_crop_choice(
            selected_crop=request.crop,
            farm_data=validated_data
        )
        
        # 2. Get all crop scores and top 3 recommendations
        all_scores = model_service.score_all_crops(validated_data)
        top_3 = all_scores[:3]
        
        # 3. Generate AI interpretation
        ai_interpretation_text = await ai_interpretation_service.generate_interpretation(
            farmer_choice=farmer_choice,
            top_recommendations=top_3,
            farm_data=validated_data,
            language=lang
        )
        
        # Calculate response time
        duration_ms = int((time.time() - start_time) * 1000)
        
        logger.info(
            f"Smart consultant prediction successful",
            extra={
                "client": client,
                "farmer_crop": farmer_choice.crop,
                "farmer_confidence": farmer_choice.confidence,
                "farmer_status": farmer_choice.status,
                "top_crop": top_3[0].crop,
                "top_confidence": top_3[0].confidence,
                "duration_ms": duration_ms
            }
        )
        
        # 4. Build response
        return SmartConsultantResponse(
            farmer_choice=FarmerChoiceResponse(
                crop=farmer_choice.crop,
                confidence_score=farmer_choice.confidence,
                status=farmer_choice.status,
                status_color=farmer_choice.color,
                validation_message=farmer_choice.message
            ),
            top_recommendations=[
                RecommendationResponse(
                    rank=i + 1,
                    crop=score.crop,
                    confidence_score=score.confidence,
                    reason=_get_recommendation_reason(score.crop, validated_data, score.confidence, lang)
                )
                for i, score in enumerate(top_3)
            ],
            ai_interpretation=AIInterpretationResponse(
                text=ai_interpretation_text,
                language=lang,
                generated_at=datetime.utcnow()
            ),
            metadata=SmartMetadataResponse(
                total_crops_analyzed=len(all_scores),
                analysis_timestamp=datetime.utcnow()
            )
        )
    
    except ValidationError as e:
        duration_ms = int((time.time() - start_time) * 1000)
        logger.warning(
            f"Validation error: {e.error_code}",
            extra={
                "error_code": e.error_code,
                "error_message": e.message,
                "duration_ms": duration_ms,
                "details": e.details
            }
        )
        raise
    
    except ModelError as e:
        duration_ms = int((time.time() - start_time) * 1000)
        logger.error(
            f"Model error: {e.error_code}",
            extra={
                "error_code": e.error_code,
                "error_message": e.message,
                "duration_ms": duration_ms,
                "details": e.details
            }
        )
        raise
    
    except Exception as e:
        duration_ms = int((time.time() - start_time) * 1000)
        logger.error(
            f"Unexpected error in smart consultant: {str(e)}",
            extra={"duration_ms": duration_ms},
            exc_info=True
        )
        raise ModelError(
            "An unexpected error occurred during smart consultant prediction",
            details={"error": str(e)}
        )
