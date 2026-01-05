import '../entities/paginated_result.dart';
import '../entities/support_chat_entity.dart';
import '../entities/support_message_entity.dart';

abstract class SupportRepository {
  Future<PaginatedResult<SupportChatEntity>> getChats({
    required int page,
    int limit,
    String? search,
    int? userId,
  });

  Future<PaginatedResult<SupportMessageEntity>> getMessages({
    required int chatId,
    required int page,
    int limit,
  });

  // Future<SupportMessageEntity?> sendText({
  //   required int chatId,
  //   required int userId,
  //   required String message,
  //   bool isAdmin = false,
  // });

  Future<SupportMessageEntity?> uploadMedia({
    required int chatId,
    required int userId,
    required String type,
    required String filePath,
    bool isAdmin = false,
  });
}
