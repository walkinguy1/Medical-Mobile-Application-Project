import 'api_client.dart';
import '../models/medicine.dart';

class MedicineService {
  final _client = ApiClient();

  Future<List<Medicine>> getMedicines({
    String? search,
    int? categoryId,
    bool? isEssential,
    double? lat,
    double? lon,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (categoryId != null) {
        queryParams['category'] = categoryId;
      }
      if (isEssential != null) {
        queryParams['is_essential'] = isEssential;
      }
      if (lat != null && lon != null) {
        queryParams['lat'] = lat;
        queryParams['lon'] = lon;
      }

      final response = await _client.dio.get('/medicines/', queryParameters: queryParams);

      return _client.parseList(response.data, Medicine.fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to load medicines catalog: $e');
    }
  }

  Future<List<MedicineCategory>> getCategories() async {
    try {
      final response = await _client.dio.get('/medicines/categories/');
      return _client.parseList(response.data, MedicineCategory.fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to load categories: $e');
    }
  }

  Future<List<PharmacyMedicineStock>> getMedicineAvailability(int medicineId) async {
    try {
      final response = await _client.dio.get('/pharmacies/stocks/', queryParameters: {
        'medicine': medicineId,
      });

      return _client.parseList(response.data, PharmacyMedicineStock.fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to load medicine availability: $e');
    }
  }
}
