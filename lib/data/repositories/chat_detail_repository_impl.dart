import '../../domain/entities/message_entity.dart';
import '../../domain/entities/paginated_result.dart';
import '../../domain/repositories/chat_detail_repository.dart';
import '../datasources/chat_detail_remote_data_source.dart';

class ChatDetailRepositoryImpl implements ChatDetailRepository {
  final ChatDetailRemoteDataSource remote;

  ChatDetailRepositoryImpl(this.remote);

  @override
  Future<PaginatedResult<MessageEntity>> getMessages({
    int? chatId,
    required int currentUserId,
    int? otherUserId,
    int page = 1,
    int limit = 20,
  }) =>
      remote.fetchMessages(
        chatId: chatId,
        currentUserId: currentUserId,
        otherUserId: otherUserId,
        page: page,
        limit: limit,
      );

  @override
  Future<MessageEntity?> uploadMedia({
    required int chatId,
    required int userId,
    required String type,
    required String filePath,
    int? receiverId,
  }) =>
      remote.uploadMedia(
        chatId: chatId,
        userId: userId,
        type: type,
        filePath: filePath,
        receiverId: receiverId,
      );
}
