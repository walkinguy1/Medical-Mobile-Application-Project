import numpy as np
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from .apps import (
    DRUG_INSIGHT_LOOKUP,
    SYMPTOM_CHECKER_MODEL,
    SYMPTOM_CHECKER_METADATA,
    DDI_LOOKUP,
)


class MedicineInsightView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, generic_name):
        # Lowercase + strip the generic_name
        drug_key = generic_name.lower().strip()
        
        # Look up in drug_insight_lookup
        record = DRUG_INSIGHT_LOOKUP.get(drug_key)
        
        if record:
            return Response({
                'drug_key': record['drug_key'],
                'review_count': record['review_count'],
                'avg_effectiveness_score': record['avg_effectiveness_score'],
                'avg_side_effect_score': record['avg_side_effect_score'],
                'most_common_condition': record['most_common_condition'],
            })
        else:
            # Return {"available": false} with HTTP 200 (NOT 404)
            return Response({'available': False}, status=status.HTTP_200_OK)


class SymptomCheckView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        symptoms = request.data.get('symptoms', [])
        
        # Validate symptoms list
        if not symptoms or not isinstance(symptoms, list):
            return Response(
                {'error': 'At least one symptom is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Load all_symptom_columns order from metadata
        all_symptom_columns = SYMPTOM_CHECKER_METADATA['all_symptom_columns']
        
        # Build numpy array of shape (1, 132)
        feature_array = np.zeros((1, len(all_symptom_columns)), dtype=float)
        
        # Set 1.0 for each symptom present in request
        for symptom in symptoms:
            if symptom in all_symptom_columns:
                idx = all_symptom_columns.index(symptom)
                feature_array[0, idx] = 1.0
        
        # Run prediction
        prediction = SYMPTOM_CHECKER_MODEL.predict(feature_array)
        predicted_condition = prediction[0]
        
        # Check if in DDA list
        dda_relevant_conditions = SYMPTOM_CHECKER_METADATA.get('dda_relevant_conditions', {})
        in_dda_list = predicted_condition in dda_relevant_conditions
        
        return Response({
            'predicted_condition': predicted_condition,
            'in_dda_list': in_dda_list,
            'disclaimer': 'This is not a medical diagnosis. Please consult a licensed pharmacist or doctor before taking any medication.'
        })


class DrugInteractionView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        current_medications = request.data.get('current_medications', [])
        target_medicine = request.data.get('target_medicine')
        
        # Validate target_medicine
        if not target_medicine:
            return Response(
                {'error': 'target_medicine is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Normalize all drug names: lowercase + strip
        target_medicine = target_medicine.lower().strip()
        current_medications = [med.lower().strip() for med in current_medications]
        
        warnings = []
        
        # For each current medication, build pair_key and lookup
        for current_med in current_medications:
            # Sort both names alphabetically and join with |||
            drug_a, drug_b = sorted([current_med, target_medicine])
            pair_key = f"{drug_a}|||{drug_b}"
            
            # Look up in DDI_LOOKUP
            interaction = DDI_LOOKUP.get(pair_key)
            if interaction:
                warnings.append({
                    'drug_a': interaction['drug_a_clean'],
                    'drug_b': interaction['drug_b_clean'],
                    'interaction_text': interaction['interaction_text'],
                })
        
        return Response({'warnings': warnings})
