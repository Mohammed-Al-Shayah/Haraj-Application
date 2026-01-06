import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/domain/entities/support_message_entity.dart';
import 'package:haraj_adan_app/features/support/controllers/support_detail_controller.dart';
import 'package:haraj_adan_app/features/chat/views/widgets/chat_bubble.dart';

class SupportBubbleList extends StatelessWidget {
  final SupportDetailController controller;

  const SupportBubbleList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final showLoader = controller.isLoadingMore.value;
      final itemCount = controller.messages.length + (showLoader ? 1 : 0);

      return ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (_, index) {
          if (showLoader && index == 0) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          final raw = controller.messages[showLoader ? index - 1 : index];

          final msg = raw.toMessageEntity(
            currentUserId: controller.currentUserId,
          );

          return ChatBubble(message: msg);
        },
      );
    });
  }
}
