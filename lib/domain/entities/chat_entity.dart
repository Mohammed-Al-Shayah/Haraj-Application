class ChatEntity {
  final int? id;
  final String name;
  final String message;
  final String time;
  final String image;
  final bool isOnline;
  final int? otherUserId;
  final int unreadCount;

  ChatEntity({
    this.id,
    required this.name,
    required this.message,
    required this.time,
    required this.image,
    required this.isOnline,
    this.otherUserId,
    this.unreadCount = 0,
  });

  ChatEntity copyWith({
    int? id,
    String? name,
    String? message,
    String? time,
    String? image,
    bool? isOnline,
    int? otherUserId,
    int? unreadCount,
  }) {
    return ChatEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      message: message ?? this.message,
      time: time ?? this.time,
      image: image ?? this.image,
      isOnline: isOnline ?? this.isOnline,
      otherUserId: otherUserId ?? this.otherUserId,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
