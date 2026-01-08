import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';
import 'package:haraj_adan_app/core/widgets/main_bar.dart';
import 'package:haraj_adan_app/features/support/controllers/support_detail_controller.dart';
import '../widgets/support_actions.dart';
import '../widgets/support_bubble_list.dart';

class SupportDetailScreen extends GetView<SupportDetailController> {
  const SupportDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final title = controller.chatName;

    return Scaffold(
      appBar: MainBar(
        title: title,
        customActions: [
          IconButton(
            onPressed: () => Get.toNamed(Routes.supportScreen),
            icon: SvgPicture.asset(
              AppAssets.headphoneIcon,
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(() {
            final presence = controller.partnerPresence.value;
            if (controller.partnerId == null || presence == null) {
              return const SizedBox.shrink();
            }

            final theme = Theme.of(context);
            final isOnline = presence == PresenceStatus.online;
            final statusColor = isOnline ? Colors.green : Colors.grey;
            final statusText = isOnline ? 'Online' : 'Offline';

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor,
                    ),
                  ),
                  Text(
                    statusText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOnline ? 'Active now' : 'Currently offline',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }),
          Expanded(child: SupportBubbleList(controller: controller)),
          SupportActions(controller: controller),
        ],
      ),
    );
  }
}
