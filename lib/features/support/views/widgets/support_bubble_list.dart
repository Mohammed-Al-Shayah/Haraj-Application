import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/domain/entities/support_message_entity.dart';
import 'package:haraj_adan_app/features/support/controllers/support_detail_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportBubbleList extends StatelessWidget {
  final SupportDetailController controller;

  const SupportBubbleList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.messages.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      final loadingMore = controller.isLoadingMore.value;
      final messages = controller.messages;
      return ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: messages.length + (loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (loadingMore && index == 0) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          final msg = messages[loadingMore ? index - 1 : index];
          return _SupportMessageBubble(
            message: msg,
            isSender: controller.isFromCurrentUser(msg),
          );
        },
      );
    });
  }
}

class _SupportMessageBubble extends StatelessWidget {
  final SupportMessageEntity message;
  final bool isSender;

  const _SupportMessageBubble({required this.message, required this.isSender});

  @override
  Widget build(BuildContext context) {
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
              if (message.message.isNotEmpty)
                Text(message.message, style: TextStyle(color: textColor)),
              if (attachment != null) ...[
                if (message.message.isNotEmpty) const SizedBox(height: 8),
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
    final url = message.mediaUrl;
    if (url == null || url.isEmpty) return null;
    final type = message.type.toLowerCase();
    if (type == 'image') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          height: 180,
          width: MediaQuery.of(context).size.width * 0.7,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 180,
              width: MediaQuery.of(context).size.width * 0.7,
              color: AppColors.gray100,
              alignment: Alignment.center,
              child: Text(
                'Image preview unavailable',
                style: TextStyle(color: AppColors.gray500),
              ),
            );
          },
        ),
      );
    }

    final icon =
        type == 'audio' ? Icons.audiotrack : Icons.insert_drive_file_outlined;
    final name = _fileNameFromUrl(url);

    return InkWell(
      onTap: () => _openUrl(url),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSender ? Colors.white.withOpacity(0.12) : AppColors.white,
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

  String _fileNameFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.last;
    }
    return message.type;
  }

  String _formatTime(DateTime date) {
    final local = date.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
