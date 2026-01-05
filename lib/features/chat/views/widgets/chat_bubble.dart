import 'dart:io';
import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/domain/entities/message_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatBubble extends StatelessWidget {
  final MessageEntity message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isSender = message.isSender;
    final bgColor = isSender ? AppColors.primary : AppColors.gray50;
    final textColor = isSender ? AppColors.white : AppColors.black75;
    final attachment = _buildAttachment(context, textColor);

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isSender ? 15 : 0),
              topRight: Radius.circular(isSender ? 0 : 15),
              bottomLeft: const Radius.circular(15),
              bottomRight: const Radius.circular(15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.text.isNotEmpty)
                Text(message.text, style: TextStyle(color: textColor)),
              if (attachment != null) ...[
                if (message.text.isNotEmpty) const SizedBox(height: 8),
                attachment,
              ],
              if (message.createdAt != null) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    _formatTime(message.createdAt!),
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildAttachment(BuildContext context, Color textColor) {
    final path =
        (message.localFilePath?.isNotEmpty == true)
            ? message.localFilePath
            : message.mediaUrl;
    if (path == null || path.isEmpty) return null;

    final type = (message.type ?? '').toLowerCase();
    final isImage =
        type == 'image' ||
        [
          '.png',
          '.jpg',
          '.jpeg',
          '.heic',
          '.webp',
          '.gif',
        ].any((ext) => path.toLowerCase().endsWith(ext));

    if (isImage) {
      final resolvedUrl = _resolveUrl(path);
      final file = File(path);
      final isNetwork = resolvedUrl.startsWith('http');
      final imageWidget =
          isNetwork
              ? Image.network(
                resolvedUrl,
                fit: BoxFit.cover,
                height: 180,
                width: MediaQuery.of(context).size.width * 0.7,
                errorBuilder: (_, __, ___) {
                  return _fallbackAttachment(context, textColor);
                },
              )
              : Image.file(
                file,
                fit: BoxFit.cover,
                height: 180,
                width: MediaQuery.of(context).size.width * 0.7,
                errorBuilder: (_, __, ___) {
                  return _fallbackAttachment(context, textColor);
                },
              );

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageWidget,
      );
    }

    final icon =
        type == 'audio' ? Icons.audiotrack : Icons.insert_drive_file_outlined;
    final name = _fileNameFromPath(path);

    return InkWell(
      onTap: () => _openAttachment(path),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:
              message.isSender
                  ? Colors.white.withOpacity(0.12)
                  : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                name,
                style: TextStyle(color: textColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.open_in_new, size: 16, color: textColor),
          ],
        ),
      ),
    );
  }

  Widget _fallbackAttachment(BuildContext context, Color textColor) {
    return Container(
      height: 180,
      width: MediaQuery.of(context).size.width * 0.7,
      color: AppColors.gray100,
      alignment: Alignment.center,
      child: Text(
        'Preview unavailable',
        style: TextStyle(color: textColor.withOpacity(0.7)),
      ),
    );
  }

  String _fileNameFromPath(String path) {
    final uri = Uri.tryParse(path);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.last;
    }
    return path.split(Platform.pathSeparator).last;
  }

  String _formatTime(DateTime date) {
    final local = date.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _openAttachment(String path) async {
    Uri? uri;
    if (path.startsWith('http')) {
      uri = Uri.tryParse(path);
    } else if (File(path).existsSync()) {
      uri = Uri.file(path);
    } else {
      uri = Uri.tryParse(_resolveUrl(path));
    }
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _resolveUrl(String path) {
    if (path.startsWith('http')) return path;
    if (File(path).existsSync()) return path;
    final base = ApiEndpoints.imageUrl;
    final normalizedBase = base.endsWith('/') ? base : '$base/';
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return '$normalizedBase$normalizedPath';
  }
}
