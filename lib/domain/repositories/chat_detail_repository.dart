import '../entities/message_entity.dart';
import '../entities/paginated_result.dart';

abstract class ChatDetailRepository {
  Future<PaginatedResult<MessageEntity>> getMessages({
    int? chatId,
    required int currentUserId,
    int? otherUserId,
    int page = 1,
    int limit = 20,
  });

  Future<MessageEntity?> uploadMedia({
    required int chatId,
    required int userId,
    required String type,
    required String filePath,
    int? receiverId,
  });
}
