import 'api_client.dart';
import '../models/ambulance.dart';

class AmbulanceService {
  final _client = ApiClient();

  Future<List<AmbulanceProvider>> getAmbulanceProviders({
    String? search,
    String? serviceType,
    String? district,
    bool? hasIcu,
    bool? hasOxygen,
    double? lat,
    double? lon,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (serviceType != null && serviceType != 'All' && serviceType.isNotEmpty) {
        queryParams['service_type'] = serviceType.toLowerCase();
      }
      if (district != null && district != 'All' && district.isNotEmpty) {
        queryParams['district'] = district;
      }
      if (hasIcu != null && hasIcu) queryParams['has_icu'] = true;
      if (hasOxygen != null && hasOxygen) queryParams['has_oxygen'] = true;
      if (lat != null && lon != null) {
        queryParams['lat'] = lat;
        queryParams['lon'] = lon;
      }

      final response = await _client.dio.get('/ambulances/', queryParameters: queryParams);

      return _client.parseList(response.data, AmbulanceProvider.fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to load ambulance providers: $e');
    }
  }
}
