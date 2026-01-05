import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/domain/entities/paginated_result.dart';
import '../models/chat_model.dart';

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

  ChatRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PaginatedResult<ChatModel>> fetchChats({
    required int userId,
    required int page,
    int limit = 10,
    String? search,
  }) async {
    final res = await apiClient.get(
      ApiEndpoints.chatList,
      queryParams: {
        'page': page,
        'limit': limit,
        'userId': userId,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    final List<dynamic> list = _extractList(res);
    final meta = _extractMeta(res);

    final items =
        list
            .whereType<Map<String, dynamic>>()
            .map((e) => ChatModel.fromMap(e, currentUserId: userId))
            .toList();
    final hasMore = _hasMore(meta, page, limit, items.length);

    return PaginatedResult<ChatModel>(
      items: items,
      page: page,
      hasMore: hasMore,
    );
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

  Map<String, dynamic>? _extractMeta(dynamic res) {
    if (res is Map<String, dynamic>) {
      if (res['meta'] is Map<String, dynamic>) return res['meta'];
      final data = res['data'];
      if (data is Map && data['meta'] is Map<String, dynamic>) {
        return data['meta'];
      }
    }
    return null;
  }

  bool _hasMore(Map<String, dynamic>? meta, int page, int limit, int fetched) {
    if (meta != null) {
      final total = meta['total'];
      if (total is num) {
        return page < total.toInt();
      }
    }
    return fetched >= limit;
  }
}
