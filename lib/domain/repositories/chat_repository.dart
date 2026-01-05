import '../entities/chat_entity.dart';
import '../entities/paginated_result.dart';

abstract class ChatRepository {
  Future<PaginatedResult<ChatEntity>> getChats({
    required int userId,
    required int page,
    int limit = 10,
    String? search,
  });
}
