import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/data/models/rejected_model.dart';

abstract class RejectedRemoteDataSource {
  Future<List<RejectedModel>> fetchAds({required int userId});
}

class RejectedRemoteDataSourceImpl implements RejectedRemoteDataSource {
  final ApiClient apiClient;

  RejectedRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<RejectedModel>> fetchAds({required int userId}) async {
    final res = await apiClient.get(
      ApiEndpoints.userAdsByStatus(userId, 'rejected'),
    );

    final list = _extractList(res);
    return list
        .whereType<Map<String, dynamic>>()
        .map(RejectedModel.fromJson)
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
