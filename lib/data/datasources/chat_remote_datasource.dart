import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/domain/entities/paginated_result.dart';
import '../models/chat_model.dart';
import 'pagination_response_parser.dart';

abstract class ChatRemoteDataSource {
  Future<PaginatedResult<ChatModel>> fetchChats({
    required int userId,
    required int page,
    int limit = 10,
    String? search,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient apiClient;
  final PaginationResponseParser _parser;

  ChatRemoteDataSourceImpl(this.apiClient, {PaginationResponseParser? parser})
    : _parser = parser ?? const PaginationResponseParser();

  @override
  Future<PaginatedResult<ChatModel>> fetchChats({
    required int userId,
    required int page,
    int limit = 10,
    String? search,
  }) async {
    final res = await apiClient.get(
      ApiEndpoints.chatList,
      queryParams: {'page': page, 'limit': limit, 'userId': userId},
    );

    final list = _parser.extractList(res);
    final meta = _parser.extractMeta(res);

    final items =
        list
            .whereType<Map<String, dynamic>>()
            .map((e) => ChatModel.fromMap(e, currentUserId: userId))
            .toList();

    final hasMore = _parser.hasMore(
      meta: meta,
      page: page,
      limit: limit,
      fetched: items.length,
    );

    return PaginatedResult<ChatModel>(
      items: items,
      page: page,
      hasMore: hasMore,
    );
  }
}
