import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/data/models/user_featured_ad_model.dart';

abstract class UserFeaturedAdsRemoteDataSource {
  Future<List<UserFeaturedAdModel>> fetchAds({required int userId});
}

class UserFeaturedAdsRemoteDataSourceImpl
    implements UserFeaturedAdsRemoteDataSource {
  final ApiClient apiClient;

  UserFeaturedAdsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<UserFeaturedAdModel>> fetchAds({required int userId}) async {
    final res = await apiClient.get(ApiEndpoints.userFeaturedAds(userId));

    final list = _extractList(res);
    return list
        .whereType<Map<String, dynamic>>()
        .map(UserFeaturedAdModel.fromJson)
        .toList();
  }

  List<dynamic> _extractList(dynamic res) {
    if (res is Map<String, dynamic>) {
      final data = res['data'];
      if (data is List) return data;
      if (data is Map && data['data'] is List) return data['data'] as List;
    }
    if (res is List) return res;
    return const [];
  }
}
