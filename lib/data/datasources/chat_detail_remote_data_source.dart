import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import '../models/message_model.dart';

abstract class ChatDetailRemoteDataSource {
  Future<List<MessageModel>> fetchMessages({
    required int chatId,
    required int userId,
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
      queryParams: {
        'chat_id': chatId,
        'chatId': chatId,
        'userId': userId,
      },
    );

    final list = _extractList(res);
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => MessageModel.fromMap(e, currentUserId: userId))
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
