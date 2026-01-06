import '../../domain/entities/chat_entity.dart';

class ChatModel extends ChatEntity {
  ChatModel({
    super.id,
    required super.name,
    required super.message,
    required super.time,
    required super.image,
    required super.isOnline,
    super.otherUserId,
    super.unreadCount = 0,
  });

  factory ChatModel.fromMap(
    Map<String, dynamic> map, {
    int? currentUserId,
  }) {
    String extractString(Map<String, dynamic> src, List<String> keys) {
      for (final key in keys) {
        final value = src[key];
        if (value == null) continue;
        final str = value.toString();
        if (str.isNotEmpty) return str;
      }
      return '';
    }

    bool extractOnline(Map<String, dynamic> src) {
      final status = src['status'] ?? src['online'];
      if (status is bool) return status;
      if (status is String) {
        final lower = status.toLowerCase();
        return lower == 'online' || lower == 'true' || lower == '1';
      }
      if (status is num) return status != 0;
      return false;
    }

    Map<String, dynamic>? extractOtherUser(Map<String, dynamic> src) {
      final members = src['members'];
      if (members is List) {
        for (final m in members) {
          if (m is! Map) continue;
          final userId = m['user_id'] ?? m['userId'];
          final uid =
              userId is num ? userId.toInt() : int.tryParse(userId?.toString() ?? '');
          if (currentUserId != null && uid != null && uid != currentUserId) {
            final user = m['users'];
            if (user is Map<String, dynamic>) return user;
          }
        }
        final first = members.first;
        if (first is Map && first['users'] is Map<String, dynamic>) {
          return first['users'] as Map<String, dynamic>;
        }
      }
      return null;
    }

    int? extractOtherUserId(Map<String, dynamic> src) {
      final members = src['members'];
      if (members is List) {
        for (final m in members) {
          if (m is! Map) continue;
          final userId = m['user_id'] ?? m['userId'];
          final uid =
              userId is num ? userId.toInt() : int.tryParse(userId?.toString() ?? '');
          if (currentUserId != null && uid != null && uid != currentUserId) {
            return uid;
          }
        }
      }
      return null;
    }

    final otherUser = extractOtherUser(map);
    int? parseInt(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '');
    }

    final unread = parseInt(map['unread_count'] ?? map['unreadCount'] ?? map['unread']);
    final lastMessage =
        map['lastMessage'] is Map ? map['lastMessage'] as Map<String, dynamic> : null;
    final messageText =
        lastMessage?['message']?.toString() ??
        extractString(map, ['message', 'last_message', 'body', 'text']);
    final messageTime =
        lastMessage?['created']?.toString() ??
        extractString(map, ['time', 'last_message_time', 'created_at', 'created']);

    return ChatModel(
      id:
          map['id'] is num
              ? (map['id'] as num).toInt()
              : map['chat_id'] is num
                  ? (map['chat_id'] as num).toInt()
                  : int.tryParse(
                      map['id']?.toString() ?? map['chat_id']?.toString() ?? '',
                    ),
      name: otherUser != null
          ? extractString(otherUser, ['name', 'user_name', 'user'])
          : extractString(map, ['name', 'user_name', 'user']),
      message: messageText,
      time: messageTime,
      image: otherUser != null
          ? extractString(otherUser, ['image', 'avatar', 'user_image'])
          : extractString(map, ['image', 'avatar', 'user_image']),
      isOnline: extractOnline(map),
      otherUserId: extractOtherUserId(map),
      unreadCount: unread ?? 0,
    );
  }
}
