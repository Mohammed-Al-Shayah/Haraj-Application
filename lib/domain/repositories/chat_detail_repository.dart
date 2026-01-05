import '../entities/message_entity.dart';

abstract class ChatDetailRepository {
  Future<List<MessageEntity>> getMessages({
    required int chatId,
    required int userId,
  });

  Future<MessageEntity?> sendText({
    required int chatId,
    required int userId,
    required String message,
    int? receiverId,
  });

  Future<MessageEntity?> uploadMedia({
    required int chatId,
    required int userId,
    required String type,
    required String filePath,
    int? receiverId,
  });
}
