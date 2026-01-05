import 'package:dio/dio.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';

import '../models/message_model.dart';

abstract class ChatDetailRemoteDataSource {
  Future<List<MessageModel>> fetchMessages({
    required int chatId,
    required int userId,
  });

  Future<MessageModel?> sendText({
    required int chatId,
    required int userId,
    required String message,
    int? receiverId,
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
  Future<List<MessageModel>> fetchMessages({
    required int chatId,
    required int userId,
  }) async {
    final res = await apiClient.get(
      ApiEndpoints.chatMessages,
      queryParams: {'chat_id': chatId, 'chatId': chatId, 'userId': userId},
    );

    final list = _extractList(res);
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => MessageModel.fromMap(e, currentUserId: userId))
        .toList();
  }

  @override
  Future<MessageModel?> sendText({
    required int chatId,
    required int userId,
    required String message,
    int? receiverId,
  }) async {
    final res = await apiClient.post(
      ApiEndpoints.chatMessages,
      data: {
        'chatId': chatId,
        'senderId': userId,
        'message': message,
        'type': 'text',
        if (receiverId != null) 'receiverId': receiverId,
      },
    );

    final data = _extractData(res);
    if (data is Map<String, dynamic>) {
      return MessageModel.fromMap(data, currentUserId: userId);
    }
    return null;
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

  dynamic _extractData(dynamic res) {
    if (res is Map<String, dynamic>) {
      return res['data'] ?? res['result'] ?? res;
    }
    return res;
  }
}
