import json
import joblib
from pathlib import Path
from django.apps import AppConfig

# Module-level globals for ML models
DRUG_INSIGHT_LOOKUP = {}
SYMPTOM_CHECKER_MODEL = None
SYMPTOM_CHECKER_METADATA = {}
DDI_LOOKUP = {}

# NOTE: DDI_LOOKUP will hold ~191k string keys with ~50MB peak RAM.
# This is acceptable for a demo server. If RAM is a concern, consider
# using SQLite/Postgres instead (out of scope for this implementation).


class MlInsightsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'ml_insights'

    def ready(self):
        global DRUG_INSIGHT_LOOKUP, SYMPTOM_CHECKER_MODEL, SYMPTOM_CHECKER_METADATA, DDI_LOOKUP
        
        # Only load if not already loaded (prevents reloading in tests)
        if DRUG_INSIGHT_LOOKUP:
            return
        
        BASE_DIR = Path(__file__).resolve().parent.parent
        MODELS_DIR = BASE_DIR / 'ml' / 'models'
        
        # Load drug_insight_lookup.json as dict keyed by drug_key
        with open(MODELS_DIR / 'drug_insight_lookup.json', 'r') as f:
            drug_insight_list = json.load(f)
            DRUG_INSIGHT_LOOKUP = {item['drug_key']: item for item in drug_insight_list}
        
        # Load symptom_checker_model.joblib
        SYMPTOM_CHECKER_MODEL = joblib.load(MODELS_DIR / 'symptom_checker_model.joblib')
        
        # Load symptom_checker_metadata.json
        with open(MODELS_DIR / 'symptom_checker_metadata.json', 'r') as f:
            SYMPTOM_CHECKER_METADATA = json.load(f)
        
        # Build DDI_LOOKUP from drug_interaction_lookup.json
        # pair_key format: "drug_a|||drug_b" where drug_a < drug_b alphabetically
        with open(MODELS_DIR / 'drug_interaction_lookup.json', 'r') as f:
            interaction_list = json.load(f)
            DDI_LOOKUP = {item['pair_key']: item for item in interaction_list}
