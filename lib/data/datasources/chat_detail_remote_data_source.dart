import 'package:dio/dio.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/domain/entities/paginated_result.dart';

import '../models/message_model.dart';

abstract class ChatDetailRemoteDataSource {
  Future<PaginatedResult<MessageModel>> fetchMessages({
    int? chatId,
    required int currentUserId,
    int? otherUserId,
    int page = 1,
    int limit = 20,
  });

  Future<MessageModel?> uploadMedia({
    required int chatId,
    required int userId,
    required String type,
    required String filePath,
    int? receiverId,
  });
}

class ChatDetailRemoteDataSourceImpl implements ChatDetailRemoteDataSource {
  final ApiClient apiClient;

  ChatDetailRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PaginatedResult<MessageModel>> fetchMessages({
    int? chatId,
    required int currentUserId,
    int? otherUserId,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await apiClient.get(
      ApiEndpoints.chatMessages,
      queryParams: {
        if (chatId != null) ...{
          'chat_id': chatId,
          'chatId': chatId,
        },
        'userId': otherUserId ?? currentUserId,
        'page': page,
        'limit': limit,
      },
    );

    final list = _extractList(res);
    final meta = _extractMeta(res);
    final items =
        list
            .whereType<Map<String, dynamic>>()
            .map((e) => MessageModel.fromMap(e, currentUserId: currentUserId))
            .toList();
    final hasMore = _hasMore(meta, page, limit, items.length);

    return PaginatedResult<MessageModel>(
      items: items,
      page: page,
      hasMore: hasMore,
    );
  }

  @override
  Future<MessageModel?> uploadMedia({
    required int chatId,
    required int userId,
    required String type,
    required String filePath,
    int? receiverId,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'chatId': chatId,
      'senderId': userId,
      if (receiverId != null) ...{'receiverId': receiverId},
    });

    final res = await apiClient.post(
      ApiEndpoints.chatMedia,
      data: formData,
      isMultipart: true,
    );

    final data = _extractData(res);
    if (data is Map<String, dynamic>) {
      return MessageModel.fromMap(data, currentUserId: userId);
    }
    return null;
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
        // meta.total represents total count of messages
        return (page * limit) < total.toInt();
      }
    }
    return fetched >= limit;
  }

  dynamic _extractData(dynamic res) {
    if (res is Map<String, dynamic>) {
      return res['data'] ?? res['result'] ?? res;
    }
    return res;
  }
}
