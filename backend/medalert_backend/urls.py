from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenVerifyView,
)
from core.views import (
    AmbulanceProviderViewSet,
    BloodBankViewSet,
    MedicineCategoryViewSet,
    MedicineViewSet,
    MedicalProfileViewSet,
    PharmacyMedicineStockViewSet,
    PharmacyViewSet,
    RegisterView,
)

router = DefaultRouter()
router.register(r'pharmacies/stocks', PharmacyMedicineStockViewSet, basename='stock')
router.register(r'pharmacies', PharmacyViewSet, basename='pharmacy')
router.register(r'medicines/categories', MedicineCategoryViewSet, basename='category')
router.register(r'medicines', MedicineViewSet, basename='medicine')
router.register(r'blood-banks', BloodBankViewSet, basename='bloodbank')
router.register(r'ambulances', AmbulanceProviderViewSet, basename='ambulance')
router.register(r'medical-id', MedicalProfileViewSet, basename='medical-profile')

api_v1 = [
    path('auth/token/', TokenObtainPairView.as_view(), name='token_obtain'),
    path('auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('auth/token/verify/', TokenVerifyView.as_view(), name='token_verify'),
    path('auth/register/', RegisterView.as_view(), name='register'),
    path('auth/profile/me/', MedicalProfileViewSet.as_view({'get': 'me', 'put': 'me', 'patch': 'me'}), name='profile_me'),
    path('', include(router.urls)),
]

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/v1/', include(api_v1)),
]
