import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';

abstract class LikesRemoteDataSource {
  Future<int> likeAd({required int adId, required int userId});
  Future<void> removeLike({required int likeId});
}

class LikesRemoteDataSourceImpl implements LikesRemoteDataSource {
  final ApiClient apiClient;
  LikesRemoteDataSourceImpl(this.apiClient);

  @override
  Future<int> likeAd({required int adId, required int userId}) async {
    final res = await apiClient.post(
      ApiEndpoints.likeAd(adId),
      data: {"userId": userId},
    );

    final data = (res['data'] as Map?) ?? {};
    final likeId = (data['id'] as num?)?.toInt();

    if (likeId == null) {
      throw Exception("Invalid like response");
    }

    return likeId;
  }

  @override
  Future<void> removeLike({required int likeId}) async {
    await apiClient.delete(ApiEndpoints.removeLike(likeId));
  }
}
