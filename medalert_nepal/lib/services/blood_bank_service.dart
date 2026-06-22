import 'api_client.dart';
import '../models/blood_bank.dart';

class BloodBankService {
  final _client = ApiClient();

  Future<List<BloodBank>> getBloodBanks({
    String? search,
    String? district,
    String? bloodGroup,
    double? lat,
    double? lon,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (district != null && district != 'All' && district.isNotEmpty) {
        queryParams['district'] = district;
      }
      if (bloodGroup != null && bloodGroup != 'All' && bloodGroup.isNotEmpty) {
        queryParams['blood_group'] = bloodGroup;
      }
      if (lat != null && lon != null) {
        queryParams['lat'] = lat;
        queryParams['lon'] = lon;
      }

      final response = await _client.dio.get('/blood-banks/', queryParameters: queryParams);

      return _client.parseList(response.data, BloodBank.fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to load blood banks: $e');
    }
  }
}
