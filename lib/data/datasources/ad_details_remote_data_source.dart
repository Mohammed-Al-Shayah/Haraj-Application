import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/features/ad_details/models/ad_details_model.dart';
import 'package:haraj_adan_app/features/ad_details/models/comment_model.dart';

abstract class AdDetailsRemoteDataSource {
  Future<AdDetailsModel?> fetchAdDetails({
    required int adId,
    String? includes,
    int? userId,
  });
  
  Future<List<CommentModel>> fetchComments({
    required int adId,
    int page,
    int limit,
  });
}

class AdDetailsRemoteDataSourceImpl implements AdDetailsRemoteDataSource {
  final ApiClient apiClient;

  AdDetailsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AdDetailsModel?> fetchAdDetails({
    required int adId,
    String? includes,
    int? userId,
  }) async {
    final res = await apiClient.get(
      ApiEndpoints.adDetails(adId),
      queryParams: {
        if (includes != null) 'includes': includes,
        if (userId != null) 'userId': userId,
      },
    );
    final data =
        res['data'] is Map<String, dynamic>
            ? res['data'] as Map<String, dynamic>
            : null;
    return data != null ? AdDetailsModel.fromJson(data) : null;
  }

  @override
  Future<List<CommentModel>> fetchComments({
    required int adId,
    int page = 1,
    int limit = 10,
  }) async {
    final res = await apiClient.get(
      ApiEndpoints.adCommentsPaginate,
      queryParams: {'adId': adId, 'page': page, 'limit': limit},
    );
    final list = res['data'] is List ? res['data'] as List : [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(CommentModel.fromJson)
        .toList();
  }
}
