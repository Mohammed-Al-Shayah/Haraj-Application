import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/data/models/ad_model.dart';
import 'package:haraj_adan_app/data/models/category_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<AdModel>> getHomeAds();
  Future<List<AdModel>> getNearbyAds({
    required double lat,
    required double lng,
    double? radius,
  });
  Future<List<CategoryModel>> getHomeCategories();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient apiClient;

  HomeRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<AdModel>> getHomeAds() async {
    final response = await apiClient.get(ApiEndpoints.adsHome);
    final list = _extractList(response);
    return list.whereType<Map<String, dynamic>>().map(AdModel.fromJson).toList();
  }

  @override
  Future<List<AdModel>> getNearbyAds({
    required double lat,
    required double lng,
    double? radius,
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.nearbyAds,
      queryParams: {
        'lat': lat,
        'lng': lng,
        if (radius != null) 'radius': radius,
      },
    );
    final list = _extractList(response);
    return list.whereType<Map<String, dynamic>>().map(AdModel.fromJson).toList();
  }

  @override
  Future<List<CategoryModel>> getHomeCategories() async {
    final response = await apiClient.get(ApiEndpoints.categoriesHome);
    final list = _extractList(response);
    return list
        .whereType<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList();
  }

  List<dynamic> _extractList(dynamic res) {
    if (res is Map && res['data'] is List) {
      return List<dynamic>.from(res['data'] as List);
    }
    if (res is List) {
      return List<dynamic>.from(res);
    }
    return <dynamic>[];
  }
}
