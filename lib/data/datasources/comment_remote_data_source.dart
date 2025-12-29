import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/features/ad_details/models/comment_model.dart';

abstract class CommentsRemoteDataSource {
  Future<CommentsPageModel> getComments({
    required int adId,
    int page,
    int limit,
  });

  Future<CommentModel> createComment({
    required int adId,
    required int userId,
    required String text,
  });
}

class CommentsRemoteDataSourceImpl implements CommentsRemoteDataSource {
  final ApiClient apiClient;

  CommentsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<CommentsPageModel> getComments({
    required int adId,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await apiClient.get(
      // todo check this url
      ApiEndpoints.adCommentsPaginate,
      queryParams: {'adId': adId, 'page': page, 'limit': limit},
    );

    return CommentsPageModel.fromJson(response);
  }

  @override
  Future<CommentModel> createComment({
    required int adId,
    required int userId,
    required String text,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.addComments(adId),
      data: {'userId': userId, 'text': text},
    );

    final rawData = response['data'];
    final Map<String, dynamic> dataMap =
        rawData is Map ? Map<String, dynamic>.from(rawData) : response;

    if (dataMap.isEmpty) {
      throw Exception('Invalid comment response');
    }

    return CommentModel.fromJson(dataMap);
  }
}
