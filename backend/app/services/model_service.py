import pickle
import pandas as pd
import os
from typing import Dict, Any

class ModelService:
    def __init__(self, model_path: str, encoders_path: str):
        self.model_path = model_path
        self.encoders_path = encoders_path
        self.model = None
        self.encoders = None
        self._load_models()

    def _load_models(self):
        if not os.path.exists(self.model_path):
            raise FileNotFoundError(f"Model file not found at {self.model_path}")
        if not os.path.exists(self.encoders_path):
            raise FileNotFoundError(f"Encoders file not found at {self.encoders_path}")

        with open(self.model_path, 'rb') as f:
            self.model = pickle.load(f)
        with open(self.encoders_path, 'rb') as f:
            self.encoders = pickle.load(f)

    def predict(self, data: Dict[str, Any]) -> str:
        try:
            # Transform inputs using encoders
            p_enc = self.encoders['province'].transform([data['province']])
            d_enc = self.encoders['district'].transform([data['district']])
            s_enc = self.encoders['season'].transform([data['season']])
            sl_enc = self.encoders['slope'].transform([data['slope']])
            sd_enc = self.encoders['seeds'].transform([data['seeds']])

            # Prepare features in the exact order trained
            # ['Province_Enc', 'District_Enc', 'Season_Enc', 'Slope_Enc', 'Seeds_Enc', 'Inorganic_Fert', 'Organic_Fert', 'Used_Lime']
            feature_names = ['Province_Enc', 'District_Enc', 'Season_Enc', 'Slope_Enc', 'Seeds_Enc', 'Inorganic_Fert', 'Organic_Fert', 'Used_Lime']
            input_df = pd.DataFrame([[
                p_enc[0], d_enc[0], s_enc[0], sl_enc[0], sd_enc[0], 
                data['inorganic_fert'], data['organic_fert'], data['used_lime']
            ]], columns=feature_names)

            # Predict
            crop_id = self.model.predict(input_df)
            recommended_crop = self.encoders['crop'].inverse_transform(crop_id)[0]
            
            return recommended_crop
        except Exception as e:
            raise Exception(f"Prediction failed: {str(e)}")

    def get_metadata(self) -> Dict[str, list]:
        return {
            'provinces': list(self.encoders['province'].classes_),
            'districts': list(self.encoders['district'].classes_),
            'seasons': list(self.encoders['season'].classes_),
            'slopes': list(self.encoders['slope'].classes_),
            'seeds': list(self.encoders['seeds'].classes_),
            'crops': list(self.encoders['crop'].classes_)
        }

# Singleton instance
MODELS_DIR = os.path.join(os.path.dirname(__file__), "../../../models")
model_service = ModelService(
    model_path=os.path.join(MODELS_DIR, "crop_model_seasonal.pkl"),
    encoders_path=os.path.join(MODELS_DIR, "encoders_seasonal.pkl")
)
