import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_detail_repository.dart';
import '../datasources/chat_detail_remote_data_source.dart';

class ChatDetailRepositoryImpl implements ChatDetailRepository {
  final ChatDetailRemoteDataSource remote;

  ChatDetailRepositoryImpl(this.remote);

  @override
  Future<List<MessageEntity>> getMessages({
    required int chatId,
    required int userId,
  }) => remote.fetchMessages(chatId: chatId, userId: userId);

  @override
  Future<MessageEntity?> sendText({
    required int chatId,
    required int userId,
    required String message,
    int? receiverId,
  }) => remote.sendText(
    chatId: chatId,
    userId: userId,
    message: message,
    receiverId: receiverId,
  );

  @override
  Future<MessageEntity?> uploadMedia({
    required int chatId,
    required int userId,
    required String type,
    required String filePath,
    int? receiverId,
  }) => remote.uploadMedia(
    chatId: chatId,
    userId: userId,
    type: type,
    filePath: filePath,
    receiverId: receiverId,
  );
}
