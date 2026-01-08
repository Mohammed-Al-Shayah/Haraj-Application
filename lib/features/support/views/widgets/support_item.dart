import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/domain/entities/support_chat_entity.dart';

class SupportItem extends StatelessWidget {
  final SupportChatEntity support;

  const SupportItem({super.key, required this.support});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap:
          () => Get.toNamed(
            Routes.supportDetailScreen,
            arguments: {
              'chatId': support.id,
              'chatName': support.name,
              'userId': support.userId,
            },
          ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            _avatar(theme),
            const SizedBox(width: 12),
            Expanded(child: _content(theme)),
            const SizedBox(width: 10),
            _meta(theme),
          ],
        ),
      ),
    );
  }

  Widget _avatar(ThemeData theme) {
    final hasImage = (support.image?.trim().isNotEmpty ?? false);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.gray100,
          backgroundImage: hasImage ? NetworkImage(support.image!) : null,
          child:
              hasImage
                  ? null
                  : Icon(Icons.support_agent, color: theme.colorScheme.primary),
        ),
        if (support.isOnline)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _content(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          support.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          support.lastMessage ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }

  Widget _meta(ThemeData theme) {
    final unread = support.unreadCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _timeLabel(support.lastMessageAt),
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.gray400,
          ),
        ),
        const SizedBox(height: 6),
        if (unread > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              unread > 99 ? '99+' : unread.toString(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  String _timeLabel(DateTime? dt) {
    if (dt == null) return '';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
