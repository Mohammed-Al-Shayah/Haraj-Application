import '../entities/message_entity.dart';

abstract class ChatDetailRepository {
  Future<List<MessageEntity>> getMessages({
    required int chatId,
    required int userId,
  });
}
