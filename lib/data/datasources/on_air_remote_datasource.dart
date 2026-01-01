import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import '../models/on_air_model.dart';

abstract class OnAirRemoteDataSource {
  Future<List<OnAirModel>> fetchAds({required int userId});
}

class OnAirRemoteDataSourceImpl implements OnAirRemoteDataSource {
  final ApiClient apiClient;

  OnAirRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<OnAirModel>> fetchAds({required int userId}) async {
    final res = await apiClient.get(
      ApiEndpoints.userAdsByStatus(userId, 'published'),
    );

    final list = _extractList(res);
    return list
        .whereType<Map<String, dynamic>>()
        .map(OnAirModel.fromJson)
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
