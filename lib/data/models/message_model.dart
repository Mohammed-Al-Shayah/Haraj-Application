import 'package:haraj_adan_app/core/network/endpoints.dart';

import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    super.id,
    super.senderId,
    required super.text,
    required super.isSender,
    super.type,
    super.isRead = false,
    super.createdAt,
    super.mediaUrl,
    super.localFilePath,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, {int? currentUserId}) {
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
        return lower == 'true' ||
            lower == '1' ||
            lower == 'me' ||
            lower == 'sender';
      }
      return false;
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    int? parseInt(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '');
    }

    String? extractMediaUrl(Map<String, dynamic> src) {
      final keys = ['file_url', 'file', 'media_url', 'url', 'attachment'];
      for (final key in keys) {
        final value = src[key];
        if (value == null) continue;
        final str = value.toString();
        if (str.isNotEmpty) return str;
      }
      return null;
    }

    final type = map['type']?.toString();
    final extractedText = extractText(map);
    String? mediaUrl = extractMediaUrl(map);

    // Some backends send only the filename in `message` for media.
    if ((mediaUrl == null || mediaUrl.isEmpty) &&
        type != null &&
        type.toLowerCase() == 'image' &&
        extractedText.isNotEmpty) {
      final filename = extractedText;
      final base = ApiEndpoints.imageUrl;
      final normalizedBase = base.endsWith('/') ? base : '$base/';
      final normalizedPath =
          filename.startsWith('/') ? filename.substring(1) : filename;
      mediaUrl = '$normalizedBase$normalizedPath';
    }

    final textValue =
        (type != null && type.toLowerCase() == 'image') ? '' : extractedText;

    return MessageModel(
      id: parseInt(map['id'] ?? map['message_id']),
      senderId: parseInt(map['sender_id'] ?? map['senderId'] ?? map['user_id']),
      text: textValue,
      isSender: extractIsSender(map),
      type: type,
      isRead: map['is_read'] == true,
      createdAt: parseDate(map['created'] ?? map['created_at']),
      mediaUrl: mediaUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (senderId != null) 'sender_id': senderId,
      'text': text,
      'isSender': isSender,
      if (type != null) 'type': type,
      'is_read': isRead,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (localFilePath != null) 'local_file_path': localFilePath,
    };
  }
}
