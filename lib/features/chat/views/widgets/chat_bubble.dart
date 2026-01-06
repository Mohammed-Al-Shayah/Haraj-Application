import 'package:flutter/material.dart';
import 'package:haraj_adan_app/domain/entities/message_entity.dart';

class ChatBubble extends StatelessWidget {
  final MessageEntity message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMe = message.isSender;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: isMe
                    ? null
                    : Border.all(
                        color:
                            theme.colorScheme.outlineVariant.withOpacity(0.35),
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((message.type ?? 'text') != 'text')
                    _attachment(theme, message, isMe),
                  if (message.text.trim().isNotEmpty)
                    Text(
                      message.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isMe ? Colors.white : null,
                        height: 1.25,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      _timeLabel(message.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: (isMe ? Colors.white : null)?.withOpacity(0.75) ??
                            theme.textTheme.labelSmall?.color?.withOpacity(0.65),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _attachment(ThemeData theme, MessageEntity m, bool isMe) {
    final label = (m.type == 'image')
        ? '📷 Image'
        : (m.type == 'file')
            ? '📎 File'
            : '📦 Attachment';

    final name = (m.mediaUrl?.trim().isNotEmpty ?? false)
        ? (m.mediaUrl!.split('/').last)
        : (m.localFilePath?.split('/').last ?? label);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.white.withOpacity(0.12)
            : theme.colorScheme.surface.withOpacity(0.75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isMe ? Colors.white : theme.colorScheme.outlineVariant)
              .withOpacity(0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.attach_file,
              size: 18, color: isMe ? Colors.white : null),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isMe ? Colors.white : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _timeLabel(DateTime? dt) {
    if (dt == null) return '';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
