import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import '../models/chat_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatModel>> fetchChats({required int userId});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient apiClient;

  ChatRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<ChatModel>> fetchChats({required int userId}) async {
    final res = await apiClient.get(
      ApiEndpoints.chatList,
      queryParams: {'userId': userId},
    );
    final List<dynamic> list = _extractList(res);

    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => ChatModel.fromMap(e, currentUserId: userId))
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
