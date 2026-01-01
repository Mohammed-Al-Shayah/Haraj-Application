class ChatEntity {
  final int? id;
  final String name;
  final String message;
  final String time;
  final String image;
  final bool isOnline;
  final int? otherUserId;

  ChatEntity({
    this.id,
    required this.name,
    required this.message,
    required this.time,
    required this.image,
    required this.isOnline,
    this.otherUserId,
  });
}
