import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';

class HomeApi {
  final ApiClient api;
  HomeApi(this.api);

  Future<List<dynamic>> getHomeAds({String? search}) async {
    final res = await api.get(
      ApiEndpoints.adsHome,
      queryParams:
          (search != null && search.trim().isNotEmpty)
              ? {'search': search.trim()}
              : null,
    );

    // حسب الدوكيومنت: البيانات دايمًا داخل data
    final data = (res['data'] is List) ? res['data'] as List : <dynamic>[];
    return data;
  }

  Future<List<dynamic>> getNearbyAds({
    required double lat,
    required double lng,
    double? radiusKm,
  }) async {
    final res = await api.get(
      ApiEndpoints.adsHome, // تأكد عندك موجود بالـ endpoints
      queryParams: {
        'lat': lat,
        'lng': lng,
        if (radiusKm != null) 'radius': radiusKm,
      },
    );

    final data = (res['data'] is List) ? res['data'] as List : <dynamic>[];
    return data;
  }

  Future<List<dynamic>> getHomeMenuCategories() async {
    final res = await api.get(ApiEndpoints.categoriesHome);

    final data = (res['data'] is List) ? res['data'] as List : <dynamic>[];
    return data;
  }
}
