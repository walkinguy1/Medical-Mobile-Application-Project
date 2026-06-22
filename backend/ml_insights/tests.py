from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from django.contrib.auth.models import User
from .apps import DRUG_INSIGHT_LOOKUP, DDI_LOOKUP


class MedicineInsightViewTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(username='testuser', password='testpass')
        self.client.force_authenticate(user=self.user)

    def test_medicine_insight_found(self):
        """Test retrieving insight for a drug that exists in lookup"""
        # Use a drug that we know exists from the lookup
        if DRUG_INSIGHT_LOOKUP:
            drug_key = list(DRUG_INSIGHT_LOOKUP.keys())[0]
            response = self.client.get(f'/api/v1/ml/medicine-insight/{drug_key}/')
            self.assertEqual(response.status_code, status.HTTP_200_OK)
            self.assertIn('drug_key', response.data)
            self.assertIn('review_count', response.data)
            self.assertIn('avg_effectiveness_score', response.data)
            self.assertIn('avg_side_effect_score', response.data)
            self.assertIn('most_common_condition', response.data)

    def test_medicine_insight_not_found(self):
        """Test retrieving insight for a drug that does not exist"""
        response = self.client.get('/api/v1/ml/medicine-insight/nonexistentdrug/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data, {'available': False})


class SymptomCheckViewTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(username='testuser2', password='testpass')
        self.client.force_authenticate(user=self.user)

    def test_symptom_check_valid(self):
        """Test symptom check with valid symptoms"""
        response = self.client.post(
            '/api/v1/ml/symptom-check/',
            {'symptoms': ['back_pain', 'headache']},
            format='json'
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('predicted_condition', response.data)
        self.assertIn('in_dda_list', response.data)
        self.assertIn('disclaimer', response.data)

    def test_symptom_check_empty(self):
        """Test symptom check with empty symptoms list"""
        response = self.client.post(
            '/api/v1/ml/symptom-check/',
            {'symptoms': []},
            format='json'
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('error', response.data)


class DrugInteractionViewTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(username='testuser3', password='testpass')
        self.client.force_authenticate(user=self.user)

    def test_drug_interaction_found(self):
        """Test drug interaction check with known interaction"""
        if DDI_LOOKUP:
            # Use a known pair from the lookup
            pair_key = list(DDI_LOOKUP.keys())[0]
            drug_a, drug_b = pair_key.split('|||')
            response = self.client.post(
                '/api/v1/ml/check-interactions/',
                {
                    'current_medications': [drug_a],
                    'target_medicine': drug_b
                },
                format='json'
            )
            self.assertEqual(response.status_code, status.HTTP_200_OK)
            self.assertIn('warnings', response.data)
            self.assertIsInstance(response.data['warnings'], list)
            # Should have at least one warning
            self.assertGreater(len(response.data['warnings']), 0)

    def test_drug_interaction_no_warnings(self):
        """Test drug interaction check with no interactions found"""
        response = self.client.post(
            '/api/v1/ml/check-interactions/',
            {
                'current_medications': ['aspirin'],
                'target_medicine': 'nonexistentdrug123'
            },
            format='json'
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('warnings', response.data)
        self.assertEqual(response.data['warnings'], [])
