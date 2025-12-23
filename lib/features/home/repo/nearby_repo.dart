import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/data/models/ad_model.dart';

class NearbyRepo {
  final ApiClient _apiClient;
  NearbyRepo(this._apiClient);

  Future<List<AdModel>> getNearby() async {
    final repo = await _apiClient.get(ApiEndpoints.nearbyAds);
    final list = _extractList(repo);
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
