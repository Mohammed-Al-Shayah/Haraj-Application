import 'package:haraj_adan_app/domain/entities/message_entity.dart';

class SupportMessageEntity {
  final int? id;
  final String message;
  final String type;
  final int? senderId;
  final bool isAdmin;
  final bool isRead;
  final DateTime? createdAt;
  final String? mediaUrl;

  const SupportMessageEntity({
    this.id,
    required this.message,
    required this.type,
    this.senderId,
    this.isAdmin = false,
    this.isRead = false,
    this.createdAt,
    this.mediaUrl,
  });
}

extension SupportMessageEntityMapper on SupportMessageEntity {
  MessageEntity toMessageEntity({int? currentUserId}) {
    final isMe =
        senderId != null && currentUserId != null && senderId == currentUserId;

    return MessageEntity(
      id: id,
      text: message,
      type: type,
      mediaUrl: mediaUrl,
      createdAt: createdAt,
      isSender: isMe,
      localFilePath: null,
    );
  }
}
