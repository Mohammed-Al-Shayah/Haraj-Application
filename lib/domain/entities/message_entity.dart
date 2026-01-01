class MessageEntity {
  final String text;
  final bool isSender;
  final String? type;
  final bool isRead;
  final DateTime? createdAt;

  MessageEntity({
    required this.text,
    required this.isSender,
    this.type,
    this.isRead = false,
    this.createdAt,
  });
}
