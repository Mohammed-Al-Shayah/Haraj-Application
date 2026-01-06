import 'package:haraj_adan_app/core/network/endpoints.dart';
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

    bool hasKnownExtension(String value) {
      final lower = value.toLowerCase();
      const exts = [
        '.png',
        '.jpg',
        '.jpeg',
        '.heic',
        '.webp',
        '.gif',
        '.pdf',
        '.doc',
        '.docx',
        '.xls',
        '.xlsx',
        '.ppt',
        '.pptx',
        '.zip',
        '.rar',
        '.mp3',
        '.wav',
        '.aac',
        '.mp4',
        '.mov',
        '.avi',
        '.mkv',
      ];
      return exts.any((ext) => lower.endsWith(ext));
    }

    String? inferTypeFromPath(String value) {
      final lower = value.toLowerCase();
      const imageExts = ['.png', '.jpg', '.jpeg', '.heic', '.webp', '.gif'];
      const audioExts = ['.mp3', '.wav', '.aac'];
      if (imageExts.any((ext) => lower.endsWith(ext))) return 'image';
      if (audioExts.any((ext) => lower.endsWith(ext))) return 'audio';
      if (hasKnownExtension(lower)) return 'file';
      return null;
    }

    String resolveUrl(String path) {
      if (path.startsWith('http')) return path;
      final base = ApiEndpoints.imageUrl;
      final normalizedBase = base.endsWith('/') ? base : '$base/';
      final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
      return '$normalizedBase$normalizedPath';
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    final sender = map['sender_id'] ?? map['senderId'] ?? map['user_id'];
    final id = map['id'] ?? map['message_id'];

    String message = pickString(map, ['message', 'text', 'body', 'content']);
    String type = map['type']?.toString() ?? 'text';
    String mediaUrl = pickString(map, ['file_url', 'file', 'media_url', 'url']);

    if (mediaUrl.isEmpty && message.isNotEmpty) {
      final inferred = inferTypeFromPath(message);
      if (inferred != null && (type.isEmpty || type == 'text')) {
        type = inferred;
      }
      if (inferred != null || message.startsWith('http')) {
        mediaUrl = resolveUrl(message);
        message = '';
      }
    }

    if (mediaUrl.isNotEmpty) {
      if (type.isEmpty || type == 'text') {
        final inferred = inferTypeFromPath(mediaUrl);
        if (inferred != null) type = inferred;
      }
      if (!mediaUrl.startsWith('http')) {
        mediaUrl = resolveUrl(mediaUrl);
      }
    }

    return SupportMessageModel(
      id: parseInt(id),
      message: message,
      type: type,
      senderId: parseInt(sender),
      isAdmin:
          map['is_admin'] == true ||
          map['isAdmin'] == true ||
          map['is_admin'] == 1 ||
          map['isAdmin'] == 1,
      isRead: map['is_read'] == true || map['isRead'] == true,
      createdAt: parseDate(map['created_at'] ?? map['created']),
      mediaUrl: mediaUrl.isEmpty ? null : mediaUrl,
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
