import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/core/network/error/exceptions.dart';
import 'package:haraj_adan_app/data/models/shopping_ad_model.dart';

abstract class ShoppingAdRemoteDataSource {
  Future<List<ShoppingAdModel>> getShoppingAds({
    required double latitude,
    required double longitude,
    double? radiusKm,
  });
}

class ShoppingAdRemoteDataSourceImpl implements ShoppingAdRemoteDataSource {
  final ApiClient apiClient;

  ShoppingAdRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<ShoppingAdModel>> getShoppingAds({
    required double latitude,
    required double longitude,
    double? radiusKm,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.nearbyAds,
        queryParams: {
          'lat': latitude,
          'lng': longitude,
          if (radiusKm != null) 'radius': radiusKm,
        },
      );

      final list = _extractList(response);
      return list
          .whereType<Map<String, dynamic>>()
          .map(_mapJsonToModel)
          .toList();
    } catch (e) {
      throw ServerException();
    }
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

  ShoppingAdModel _mapJsonToModel(Map<String, dynamic> json) {
    final model = ShoppingAdModel.fromJson(json);
    final image = model.imageUrl;
    final fullImage =
        image.startsWith('http') ? image : '${ApiEndpoints.imageUrl}$image';
    final currency =
        (json['currencies'] is Map)
            ? json['currencies']['symbol']?.toString()
            : null;

    return ShoppingAdModel.fromJson({
      'id': model.id,
      'title': model.title,
      'address': model.location,
      'price': model.price,
      'ads_images': [
        {'image': fullImage},
      ],
      if (currency != null) 'currencies': {'symbol': currency},
    });
  }
}
