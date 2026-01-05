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
