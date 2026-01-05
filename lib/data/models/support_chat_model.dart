import 'package:haraj_adan_app/domain/entities/support_chat_entity.dart';

class SupportChatModel extends SupportChatEntity {
  const SupportChatModel({
    required super.id,
    required super.name,
    super.lastMessage,
    super.lastMessageAt,
    super.image,
    super.isOnline = false,
    super.unreadCount = 0,
    super.userId,
  });

  factory SupportChatModel.fromMap(
    Map<String, dynamic> map, {
    int? currentUserId,
  }) {
    Map<String, dynamic>? pickUser(Map<String, dynamic> src) {
      final users = src['users'];
      if (users is List && users.isNotEmpty) {
        for (final user in users) {
          if (user is! Map<String, dynamic>) continue;
          final id = user['id'] ?? user['user_id'];
          final parsedId =
              id is num ? id.toInt() : int.tryParse(id?.toString() ?? '');
          if (currentUserId != null &&
              parsedId != null &&
              parsedId != currentUserId) {
            return user;
          }
        }
        final first = users.first;
        if (first is Map<String, dynamic>) return first;
      }
      return null;
    }

    Map<String, dynamic>? pickLastMessage(Map<String, dynamic> src) {
      if (src['lastMessage'] is Map<String, dynamic>) {
        return src['lastMessage'] as Map<String, dynamic>;
      }
      final msgs = src['support_chat_messages'];
      if (msgs is List && msgs.isNotEmpty) {
        final last = msgs.last;
        if (last is Map<String, dynamic>) return last;
      }
      return null;
    }

    String pickString(Map<String, dynamic> src, List<String> keys) {
      for (final key in keys) {
        final value = src[key];
        if (value == null) continue;
        final text = value.toString();
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    bool pickOnline(Map<String, dynamic> src, Map<String, dynamic>? user) {
      final value = src['isOnline'] ?? src['online'] ?? src['status'];
      final userValue = user?['isOnline'] ?? user?['online'] ?? user?['status'];
      final useValue = userValue ?? value;
      if (useValue is bool) return useValue;
      if (useValue is num) return useValue != 0;
      if (useValue is String) {
        final lower = useValue.toLowerCase();
        return lower == 'online' || lower == 'true' || lower == '1';
      }
      return false;
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    int parseInt(dynamic v, [int fallback = 0]) {
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? fallback;
    }

    final user = pickUser(map);
    final lastMessage = pickLastMessage(map);

    final id = map['id'] ?? map['support_chat_id'];
    final parsedId =
        id is num ? id.toInt() : int.tryParse(id?.toString() ?? '') ?? 0;

    return SupportChatModel(
      id: parsedId,
      name:
          user != null
              ? pickString(user, ['name', 'full_name', 'username'])
              : pickString(map, ['name', 'title']),
      lastMessage: pickString(lastMessage ?? map, [
        'message',
        'text',
        'last_message',
      ]),
      lastMessageAt: parseDate(
        lastMessage != null
            ? lastMessage['created_at'] ?? lastMessage['created']
            : map['last_message_at'],
      ),
      image:
          user != null
              ? pickString(user, ['image', 'avatar', 'profile'])
              : pickString(map, ['image', 'avatar', 'profile']),
      isOnline: pickOnline(map, user),
      unreadCount: parseInt(map['unread_count'] ?? map['unreadCount'], 0),
      userId:
          user != null
              ? (user['id'] is num
                  ? (user['id'] as num).toInt()
                  : int.tryParse(user['id']?.toString() ?? ''))
              : null,
    );
  }
}
