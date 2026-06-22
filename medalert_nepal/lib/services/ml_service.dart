import 'api_client.dart';

class MlService {
  final _client = ApiClient();

  Future<Map<String, dynamic>?> getMedicineInsight(String genericName) async {
    try {
      final response = await _client.dio.get(
        '/ml/medicine-insight/$genericName/',
      );

      if (response.data['available'] == false) {
        return null;
      }

      return response.data as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to load medicine insight: $e');
    }
  }

  Future<Map<String, dynamic>> checkSymptoms(List<String> symptoms) async {
    try {
      final response = await _client.dio.post(
        '/ml/symptom-check/',
        data: {'symptoms': symptoms},
      );

      return response.data as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to check symptoms: $e');
    }
  }

  Future<List<Map<String, dynamic>>> checkInteractions(
    List<String> currentMeds,
    String targetMedicine,
  ) async {
    try {
      final response = await _client.dio.post(
        '/ml/check-interactions/',
        data: {
          'current_medications': currentMeds,
          'target_medicine': targetMedicine,
        },
      );

      final warnings = response.data['warnings'] as List;
      return warnings.map((w) => w as Map<String, dynamic>).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to check drug interactions: $e');
    }
  }
}
