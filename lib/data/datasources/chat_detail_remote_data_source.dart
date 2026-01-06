import 'package:dio/dio.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/domain/entities/paginated_result.dart';
import '../models/message_model.dart';
import 'pagination_response_parser.dart';

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
  final PaginationResponseParser _parser;

  ChatDetailRemoteDataSourceImpl(this.apiClient, {PaginationResponseParser? parser})
      : _parser = parser ?? const PaginationResponseParser();

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
        if (chatId != null) ...{'chat_id': chatId, 'chatId': chatId},
        // Keep backend compatibility:
        'userId': otherUserId ?? currentUserId,
        'page': page,
        'limit': limit,
      },
    );

    final list = _parser.extractList(res);
    final meta = _parser.extractMeta(res);

    final items = list
        .whereType<Map<String, dynamic>>()
        .map((e) => MessageModel.fromMap(e, currentUserId: currentUserId))
        .toList();

    final hasMore = _parser.hasMore(meta: meta, page: page, limit: limit, fetched: items.length);

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
      'chat_id': chatId,
      'senderId': userId,
      'sender_id': userId,
      if (receiverId != null) ...{
        'receiverId': receiverId,
        'receiver_id': receiverId,
      },
      'type': type,
    });

    final res = await apiClient.post(
      ApiEndpoints.chatMedia,
      data: formData,
      isMultipart: true,
    );

    final data = _parser.extractData(res);
    if (data is Map<String, dynamic>) {
      return MessageModel.fromMap(data, currentUserId: userId);
    }
    return null;
  }
}
