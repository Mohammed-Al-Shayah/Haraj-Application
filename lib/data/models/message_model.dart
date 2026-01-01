import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    required super.text,
    required super.isSender,
    super.type,
    super.isRead = false,
    super.createdAt,
  });

  factory MessageModel.fromMap(
    Map<String, dynamic> map, {
    int? currentUserId,
  }) {
    String extractText(Map<String, dynamic> src) {
      final keys = ['text', 'message', 'body', 'content'];
      for (final key in keys) {
        final value = src[key];
        if (value != null) return value.toString();
      }
      return '';
    }

    bool extractIsSender(Map<String, dynamic> src) {
      final v =
          src['isSender'] ??
          src['is_sender'] ??
          src['from_me'] ??
          src['sender_id'];
      if (v is bool) return v;
      if (v is num) {
        if (currentUserId != null) return v.toInt() == currentUserId;
        return v != 0;
      }
      if (v is String) {
        final lower = v.toLowerCase();
        if (currentUserId != null) {
          final parsed = int.tryParse(lower);
          if (parsed != null) return parsed == currentUserId;
        }
        return lower == 'true' || lower == '1' || lower == 'me' || lower == 'sender';
      }
      return false;
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return MessageModel(
      text: extractText(map),
      isSender: extractIsSender(map),
      type: map['type']?.toString(),
      isRead: map['is_read'] == true,
      createdAt: parseDate(map['created'] ?? map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isSender': isSender,
      if (type != null) 'type': type,
      'is_read': isRead,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
