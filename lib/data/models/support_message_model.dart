import 'package:haraj_adan_app/domain/entities/support_message_entity.dart';

class SupportMessageModel extends SupportMessageEntity {
  const SupportMessageModel({
    super.id,
    required super.message,
    required super.type,
    super.senderId,
    super.isAdmin = false,
    super.isRead = false,
    super.createdAt,
    super.mediaUrl,
  });

  factory SupportMessageModel.fromMap(
    Map<String, dynamic> map, {
    int? currentUserId,
  }) {
    String pickString(Map<String, dynamic> src, List<String> keys) {
      for (final key in keys) {
        final value = src[key];
        if (value == null) continue;
        final text = value.toString();
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    int? parseInt(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '');
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    final sender = map['sender_id'] ?? map['senderId'] ?? map['user_id'];
    final id = map['id'] ?? map['message_id'];

    return SupportMessageModel(
      id: parseInt(id),
      message: pickString(map, ['message', 'text', 'body', 'content']),
      type: map['type']?.toString() ?? 'text',
      senderId: parseInt(sender),
      isAdmin: map['is_admin'] == true || map['isAdmin'] == true,
      isRead: map['is_read'] == true || map['isRead'] == true,
      createdAt: parseDate(map['created_at'] ?? map['created']),
      mediaUrl: pickString(map, ['file_url', 'file', 'media_url', 'url']),
    );
  }

  factory SupportMessageModel.pendingText({
    required String text,
    required int senderId,
    required bool isAdmin,
  }) {
    return SupportMessageModel(
      id: null,
      message: text,
      type: 'text',
      senderId: senderId,
      isAdmin: isAdmin,
      isRead: true,
      createdAt: DateTime.now(),
    );
  }
}
