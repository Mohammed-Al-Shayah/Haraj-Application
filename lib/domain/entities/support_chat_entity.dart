class SupportChatEntity {
  final int id;
  final String name;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? image;
  final bool isOnline;
  final int unreadCount;
  final int? userId;

  const SupportChatEntity({
    required this.id,
    required this.name,
    this.lastMessage,
    this.lastMessageAt,
    this.image,
    this.isOnline = false,
    this.unreadCount = 0,
    this.userId,
  });
}
