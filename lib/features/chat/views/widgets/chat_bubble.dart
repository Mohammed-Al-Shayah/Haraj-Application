import 'dart:io';

import 'package:flutter/material.dart';
import 'package:haraj_adan_app/domain/entities/message_entity.dart';
import 'package:haraj_adan_app/core/theme/color.dart';

class ChatBubble extends StatelessWidget {
  final MessageEntity message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMe = message.isSender;
    final textColor = isMe ? AppColors.white : AppColors.gray950;
    final timeColor = isMe ? AppColors.white75 : AppColors.gray500;
    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: IntrinsicWidth(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isMe ? AppColors.primary : AppColors.gray200,
                    ),
                    boxShadow: [
                      if (!isMe)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                    ],
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
                            color: textColor,
                            height: 1.25,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          _timeLabel(message.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: timeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _attachment(ThemeData theme, MessageEntity m, bool isMe) {
    final isImage = (m.type ?? '').toLowerCase() == 'image';
    final hasUrl = (m.mediaUrl?.trim().isNotEmpty ?? false);
    final hasLocal = (m.localFilePath?.trim().isNotEmpty ?? false);

    if (isImage && (hasUrl || hasLocal)) {
      final Widget image;
      if (hasLocal) {
        image = Image.file(
          File(m.localFilePath!),
          fit: BoxFit.cover,
        );
      } else {
        image = Image.network(
          m.mediaUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
          errorBuilder: (context, error, stack) => const SizedBox(
            height: 120,
            child: Center(child: Icon(Icons.broken_image)),
          ),
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: image,
          ),
        ),
      );
    }

    final typeValue = (m.type ?? '').toLowerCase();
    final url = m.mediaUrl?.toLowerCase() ?? '';
    final localPath = m.localFilePath?.toLowerCase() ?? '';
    final isPdf = typeValue == 'pdf' ||
        url.endsWith('.pdf') ||
        localPath.endsWith('.pdf');

    const label = 'Attachment';
    final name = hasUrl
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPdf ? Icons.picture_as_pdf : Icons.attach_file,
                size: 18,
                color: isMe ? Colors.white : null,
              ),
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
          if (isPdf)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'PDF Document',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isMe
                      ? Colors.white70
                      : theme.textTheme.bodySmall?.color?.withOpacity(0.7),
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
