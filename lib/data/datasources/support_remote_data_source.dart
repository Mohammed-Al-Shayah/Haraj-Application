import 'package:dio/dio.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/domain/entities/paginated_result.dart';
import '../models/support_chat_model.dart';
import '../models/support_message_model.dart';

abstract class SupportRemoteDataSource {
  Future<PaginatedResult<SupportChatModel>> fetchChats({
    required int page,
    int limit,
    String? search,
  });

  Future<PaginatedResult<SupportMessageModel>> fetchMessages({
    required int chatId,
    required int page,
    int limit,
  });

  Future<SupportMessageModel?> sendText({
    required int chatId,
    required int userId,
    required String message,
    bool isAdmin = false,
  });

  Future<SupportMessageModel?> uploadMedia({
    required int chatId,
    required int userId,
    required String type,
    required String filePath,
    bool isAdmin = false,
  });
}

class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  final ApiClient apiClient;

  SupportRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PaginatedResult<SupportChatModel>> fetchChats({
    required int page,
    int limit = 10,
    String? search,
  }) async {
    dynamic res;
    final query = {
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    try {
      res = await apiClient.get(
        ApiEndpoints.supportChatsCustomerPaginate,
        queryParams: query,
      );
    } on Object {
      // Fallback for older backends that don't expose the customer endpoint.
      res = await apiClient.get(
        ApiEndpoints.supportChatsPaginate,
        queryParams: query,
      );
    }

    final list = _extractList(res);
    final meta = _extractMeta(res);
    final items =
        list
            .whereType<Map<String, dynamic>>()
            .map((e) => SupportChatModel.fromMap(e))
            .toList();

    final hasMore = _hasMore(meta, page, limit, items.length);

    return PaginatedResult<SupportChatModel>(
      items: items,
      page: page,
      hasMore: hasMore,
    );
  }

  @override
  Future<PaginatedResult<SupportMessageModel>> fetchMessages({
    required int chatId,
    required int page,
    int limit = 20,
  }) async {
    final res = await apiClient.get(
      ApiEndpoints.supportChatDetail(chatId),
      queryParams: {'page': page, 'limit': limit},
    );

    final list = _extractList(res);
    final meta = _extractMeta(res);
    final items =
        list
            .whereType<Map<String, dynamic>>()
            .map((e) => SupportMessageModel.fromMap(e))
            .toList();

    final hasMore = _hasMore(meta, page, limit, items.length);

    return PaginatedResult<SupportMessageModel>(
      items: items,
      page: page,
      hasMore: hasMore,
    );
  }

  @override
  Future<SupportMessageModel?> sendText({
    required int chatId,
    required int userId,
    required String message,
    bool isAdmin = false,
  }) async {
    final data = {
      'chatId': chatId,
      'support_chat_id': chatId,
      'message': message,
      'type': 'text',
      'userId': userId,
      'sender_id': userId,
      'is_admin': isAdmin ? 1 : 0,
    };

    dynamic res;
    try {
      res = await apiClient.post(ApiEndpoints.supportChatMessages, data: data);
    } on Object {
      res = await apiClient.post(ApiEndpoints.supportChats, data: data);
    }

    _extractData(res);
    return SupportMessageModel.fromMap(data);
  }

  @override
  Future<SupportMessageModel?> uploadMedia({
    required int chatId,
    required int userId,
    required String type,
    required String filePath,
    bool isAdmin = false,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'chatId': chatId,
      'type': type,
      'userId': userId,
      'is_admin': isAdmin ? 1 : 0,
    });

    final res = await apiClient.post(
      ApiEndpoints.supportChatMedia,
      data: formData,
      isMultipart: true,
    );

    final data = _extractData(res);
    if (data is Map<String, dynamic>) {
      return SupportMessageModel.fromMap(data);
    }
    return null;
  }

  List<dynamic> _extractList(dynamic res) {
    if (res is Map<String, dynamic>) {
      final data = res['data'];
      if (data is List) return data;
      if (data is Map) {
        if (data['data'] is List) return data['data'] as List;
        if (data['support_chat_messages'] is List) {
          return data['support_chat_messages'] as List;
        }
      }
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

  dynamic _extractData(dynamic res) {
    if (res is Map<String, dynamic>) {
      return res['data'] ?? res['result'] ?? res;
    }
    return res;
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
