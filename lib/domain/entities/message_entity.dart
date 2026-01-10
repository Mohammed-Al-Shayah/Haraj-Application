class MessageEntity {
  final int? id;
  final int? senderId;
  final int? chatId;
  final String text;
  final bool isSender;
  final String? type;
  final bool isRead;
  final DateTime? createdAt;
  final String? mediaUrl;
  final String? localFilePath;

  MessageEntity({
    this.id,
    this.senderId,
    this.chatId,
    required this.text,
    required this.isSender,
    this.type,
    this.isRead = false,
    this.createdAt,
    this.mediaUrl,
    this.localFilePath,
  });
}
