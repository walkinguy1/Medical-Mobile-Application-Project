from django.urls import path
from .views import MedicineInsightView, SymptomCheckView, DrugInteractionView

urlpatterns = [
    path('medicine-insight/<str:generic_name>/', MedicineInsightView.as_view(), name='medicine-insight'),
    path('symptom-check/', SymptomCheckView.as_view(), name='symptom-check'),
    path('check-interactions/', DrugInteractionView.as_view(), name='check-interactions'),
]
