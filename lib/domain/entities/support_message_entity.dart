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


extension SupportMessageMapper on SupportMessageEntity {
  MessageEntity toMessageEntity({
    required int? currentUserId,
  }) {
    return MessageEntity(
      id: id,
      senderId: senderId,
      text: message,
      // بما أن رسالة الدعم:
      // isAdmin == true  => الرسالة من الدعم
      // isAdmin == false => من المستخدم
      isSender: !isAdmin && senderId == currentUserId,
      type: type,
      isRead: isRead,
      createdAt: createdAt,
      mediaUrl: mediaUrl,
      localFilePath: null,
    );
  }
}
