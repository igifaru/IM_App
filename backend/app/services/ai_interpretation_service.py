"""AI-powered interpretation service using Groq/Llama"""

from groq import Groq
from typing import Dict, List, Any
import os
from app.core.logging import logger
from app.core.config import settings
from app.services.model_service import CropValidation, CropScore


class AIInterpretationService:
    """Service for generating AI-powered crop interpretations"""
    
    def __init__(self):
        """Initialize Groq client"""
        api_key = settings.GROQ_API_KEY
        if not api_key:
            logger.warning("GROQ_API_KEY not set - AI interpretations will use fallback templates")
            self.client = None
        else:
            try:
                self.client = Groq(api_key=api_key)
                self.model = "llama-3.3-70b-versatile"  # Updated to current model
                logger.info(f"AI interpretation service initialized successfully with model: {self.model}")
            except Exception as e:
                logger.error(f"Failed to initialize Groq client: {str(e)}")
                self.client = None
    
    async def generate_interpretation(
        self,
        farmer_choice: CropValidation,
        top_recommendations: List[CropScore],
        farm_data: Dict[str, Any],
        language: str = "en"
    ) -> str:
        """
        Generate AI interpretation comparing farmer's choice with recommendations.
        
        Args:
            farmer_choice: Validated farmer's crop choice
            top_recommendations: Top 3 recommended crops
            farm_data: Farm conditions
            language: Target language (en/fr/rw)
        
        Returns:
            Natural language interpretation
        """
        if not self.client:
            return self._get_fallback_interpretation(
                farmer_choice,
                top_recommendations,
                language
            )
        
        prompt = self._build_prompt(
            farmer_choice,
            top_recommendations,
            farm_data,
            language
        )
        
        try:
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {
                        "role": "system",
                        "content": self._get_system_prompt(language)
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                temperature=0.7,
                max_tokens=600,  # Increased for more detailed responses
                timeout=10.0  # Increased timeout for better quality
            )
            
            interpretation = response.choices[0].message.content
            logger.info(
                "AI interpretation generated successfully",
                extra={
                    "language": language,
                    "farmer_crop": farmer_choice.crop,
                    "top_crop": top_recommendations[0].crop,
                    "model": self.model
                }
            )
            return interpretation
        
        except Exception as e:
            logger.error(f"AI interpretation failed: {str(e)}", exc_info=True)
            return self._get_fallback_interpretation(
                farmer_choice,
                top_recommendations,
                language
            )
    
    def _build_prompt(
        self,
        farmer_choice: CropValidation,
        top_recommendations: List[CropScore],
        farm_data: Dict[str, Any],
        language: str
    ) -> str:
        """Build detailed agronomic prompt for AI interpretation"""
        
        lang_names = {
            "en": "English",
            "fr": "French",
            "rw": "Kinyarwanda"
        }
        
        # Build detailed farm analysis
        slope_text = "sloped terrain" if farm_data.get('slope') == 'Yes' else "flat terrain"
        fert_status = []
        if farm_data.get('inorganic_fert') == 1:
            fert_status.append("inorganic fertilizer")
        if farm_data.get('organic_fert') == 1:
            fert_status.append("organic fertilizer")
        if farm_data.get('used_lime') == 1:
            fert_status.append("lime application")
        
        fert_text = ", ".join(fert_status) if fert_status else "no fertilizers"
        
        prompt = f"""You are an expert agronomist in Rwanda analyzing crop suitability for a farmer.

FARM CONDITIONS:
- Location: {farm_data.get('district', 'Unknown')} District, {farm_data.get('province', 'Unknown')} Province
- Growing Season: {farm_data.get('season', 'Unknown')}
- Terrain: {slope_text}
- Seed Quality: {farm_data.get('seeds', 'Unknown')}
- Soil Management: {fert_text}

FARMER'S CROP CHOICE:
- Selected Crop: {farmer_choice.crop}
- ML Model Confidence: {farmer_choice.confidence:.1%}
- Suitability Status: {farmer_choice.status}

TOP 3 ML-RECOMMENDED CROPS (Based on historical data from similar conditions):
1. {top_recommendations[0].crop} - {top_recommendations[0].confidence:.1%} confidence
2. {top_recommendations[1].crop} - {top_recommendations[1].confidence:.1%} confidence
3. {top_recommendations[2].crop} - {top_recommendations[2].confidence:.1%} confidence

TASK:
As an agronomist, provide a professional analysis in {lang_names.get(language, 'English')} that:

1. VALIDATES or QUESTIONS the farmer's choice based on the ML confidence score
2. EXPLAINS the agronomic reasoning (why certain crops score higher based on location, season, soil management)
3. PROVIDES specific actionable advice related to their actual farm conditions
4. Uses a supportive, educational tone (not judgmental)
5. Keeps response concise (3-4 sentences maximum)
6. References actual farm factors (fertilizer use, slope, season, location)

Focus on REAL agronomic factors, not generic advice. Be specific about why the ML model recommends certain crops for THIS farmer's specific conditions."""
        return prompt
    
    def _get_system_prompt(self, language: str) -> str:
        """Get system prompt for AI"""
        
        prompts = {
            "en": "You are a professional agronomist with 20+ years of experience in Rwandan agriculture. You analyze ML model predictions and provide evidence-based, practical advice to farmers. Your responses are grounded in agronomic science, local conditions, and historical crop performance data. You explain technical concepts in simple terms farmers can understand.",
            "fr": "Vous êtes un agronome professionnel avec plus de 20 ans d'expérience dans l'agriculture rwandaise. Vous analysez les prédictions du modèle ML et fournissez des conseils pratiques et fondés sur des preuves aux agriculteurs. Vos réponses sont basées sur la science agronomique, les conditions locales et les données historiques de performance des cultures. Vous expliquez les concepts techniques en termes simples que les agriculteurs peuvent comprendre.",
            "rw": "Uri umuhanga mu buhinzi ufite uburambe bw'imyaka 20+ mu buhinzi mu Rwanda. Usesengura ibisubizo bya ML model kandi utanga inama zifatika kandi zishingiye ku bimenyetso ku bahinzi. Ibisubizo byawe bishingiye ku bumenyi bw'ubuhinzi, ibihugu by'aho, n'amakuru y'amateka y'umusaruro w'ibihingwa. Usobanura ibitekerezo bya tekiniki mu magambo yoroshye abahinzi bashobora gusobanukirwa."
        }
        
        return prompts.get(language, prompts["en"])
    
    def _get_fallback_interpretation(
        self,
        farmer_choice: CropValidation,
        top_recommendations: List[CropScore],
        language: str
    ) -> str:
        """Enhanced fallback interpretation with agronomic reasoning"""
        
        # Check if farmer's choice is in top 3
        farmer_in_top_3 = any(
            rec.crop == farmer_choice.crop 
            for rec in top_recommendations[:3]
        )
        
        # Calculate confidence difference
        top_confidence = top_recommendations[0].confidence
        choice_confidence = farmer_choice.confidence
        confidence_diff = top_confidence - choice_confidence
        
        if farmer_in_top_3:
            # Farmer made a good choice - provide positive reinforcement
            templates = {
                "en": f"Excellent agronomic decision! {farmer_choice.crop} is among our top recommendations with a {farmer_choice.confidence:.0%} success rate based on historical data from similar conditions in your area. This crop aligns well with your soil management practices and seasonal conditions.",
                "fr": f"Excellente décision agronomique ! {farmer_choice.crop} figure parmi nos meilleures recommandations avec un taux de réussite de {farmer_choice.confidence:.0%} basé sur des données historiques de conditions similaires dans votre région. Cette culture s'aligne bien avec vos pratiques de gestion des sols et les conditions saisonnières.",
                "rw": f"Icyemezo cyiza cyo guhinga! {farmer_choice.crop} ni kimwe mu bihingwa byasabwe cyane hamwe na {farmer_choice.confidence:.0%} yo gutsinda bishingiye ku makuru y'amateka y'ibihugu bisa n'ibyawe. Iki gihingwa kirakwiriye uburyo bwawe bwo gucunga ubutaka n'ibihe by'ihinga."
            }
        elif farmer_choice.status == "good" and confidence_diff < 0.15:
            # Good choice but slightly lower than top - provide nuanced advice
            templates = {
                "en": f"Your choice of {farmer_choice.crop} is agronomically sound with a {farmer_choice.confidence:.0%} success rate. However, {top_recommendations[0].crop} shows {top_confidence:.0%} confidence based on similar farms in your district. The difference is marginal, but {top_recommendations[0].crop} may offer slightly better yields given your fertilizer practices.",
                "fr": f"Votre choix de {farmer_choice.crop} est agronomiquement solide avec un taux de {farmer_choice.confidence:.0%}. Cependant, {top_recommendations[0].crop} montre {top_confidence:.0%} de confiance basé sur des fermes similaires dans votre district. La différence est marginale, mais {top_recommendations[0].crop} pourrait offrir des rendements légèrement meilleurs compte tenu de vos pratiques de fertilisation.",
                "rw": f"Amahitamo yawe ya {farmer_choice.crop} ni meza mu buhinzi hamwe na {farmer_choice.confidence:.0%} yo gutsinda. Ariko, {top_recommendations[0].crop} yerekana {top_confidence:.0%} yo gutsinda bishingiye ku mirima isa n'iyawe mu karere kawe. Itandukaniro ni rito, ariko {top_recommendations[0].crop} rishobora gutanga umusaruro mwiza cyane urebye uburyo bwawe bwo gukoresha ifumbire."
            }
        elif farmer_choice.status == "moderate":
            # Moderate choice - provide clear alternatives with reasoning
            templates = {
                "en": f"Based on agronomic analysis, {farmer_choice.crop} shows {farmer_choice.confidence:.0%} suitability for your conditions. Our model suggests {top_recommendations[0].crop} ({top_confidence:.0%}) or {top_recommendations[1].crop} ({top_recommendations[1].confidence:.0%}) would perform better given your location, season, and soil management. These crops have shown higher yields in similar conditions.",
                "fr": f"Selon l'analyse agronomique, {farmer_choice.crop} montre {farmer_choice.confidence:.0%} d'adaptation à vos conditions. Notre modèle suggère que {top_recommendations[0].crop} ({top_confidence:.0%}) ou {top_recommendations[1].crop} ({top_recommendations[1].confidence:.0%}) performeraient mieux compte tenu de votre emplacement, saison et gestion des sols. Ces cultures ont montré des rendements plus élevés dans des conditions similaires.",
                "rw": f"Ukurikije isesengura ry'ubuhinzi, {farmer_choice.crop} yerekana {farmer_choice.confidence:.0%} yo gukwiriye ibihugu byawe. Moderi yacu irasaba {top_recommendations[0].crop} ({top_confidence:.0%}) cyangwa {top_recommendations[1].crop} ({top_recommendations[1].confidence:.0%}) byakora neza urebye ahantu utuye, igihe, n'uburyo bwo gucunga ubutaka. Ibi bihingwa byerekanye umusaruro mwinshi mu bihugu bisa."
            }
        else:
            # Poor choice - provide strong but supportive guidance
            templates = {
                "en": f"Agronomic assessment indicates {farmer_choice.crop} has only {farmer_choice.confidence:.0%} success probability in your specific conditions. We strongly recommend {top_recommendations[0].crop} ({top_confidence:.0%}) or {top_recommendations[1].crop} ({top_recommendations[1].confidence:.0%}) instead. These crops are significantly better suited to your district's soil, climate, and your current fertilizer practices, based on extensive historical data.",
                "fr": f"L'évaluation agronomique indique que {farmer_choice.crop} n'a que {farmer_choice.confidence:.0%} de probabilité de succès dans vos conditions spécifiques. Nous recommandons fortement {top_recommendations[0].crop} ({top_confidence:.0%}) ou {top_recommendations[1].crop} ({top_recommendations[1].confidence:.0%}) à la place. Ces cultures sont nettement mieux adaptées au sol, au climat de votre district et à vos pratiques actuelles de fertilisation, selon des données historiques étendues.",
                "rw": f"Isuzuma ry'ubuhinzi ryerekana ko {farmer_choice.crop} ifite {farmer_choice.confidence:.0%} gusa yo gutsinda mu bihugu byawe. Turasaba cyane {top_recommendations[0].crop} ({top_confidence:.0%}) cyangwa {top_recommendations[1].crop} ({top_recommendations[1].confidence:.0%}) aho. Ibi bihingwa birakwiriye cyane ubutaka, ikirere cy'akarere kawe, n'uburyo bwawe bwo gukoresha ifumbire, ukurikije amakuru menshi y'amateka."
            }
        
        return templates.get(language, templates["en"])


# Singleton instance
ai_interpretation_service = AIInterpretationService()
