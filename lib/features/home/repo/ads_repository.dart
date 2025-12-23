import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import '../models/ads/add_model.dart';

class AdsRepository {
  final ApiClient _apiClient;

  AdsRepository(this._apiClient);

  Future<List<AdModel>> getAllAds() async {
    final res = await _apiClient.get(ApiEndpoints.adsHome);
    final list = _extractList(res);
    return list.whereType<Map<String, dynamic>>().map(AdModel.fromJson).toList();
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
