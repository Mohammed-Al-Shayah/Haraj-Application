import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';
import 'package:haraj_adan_app/core/widgets/main_bar.dart';
import 'package:haraj_adan_app/features/chat/controllers/chat_detail_controller.dart';
import '../widgets/chat_actions.dart';
import '../widgets/chat_bubble.dart';

class ChatDetailScreen extends GetView<ChatDetailController> {
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatName = controller.chatName;

    return Scaffold(
      appBar: MainBar(
        title: chatName,
        customActions: [
          IconButton(
            icon: SvgPicture.asset(AppAssets.callIcon, width: 24, height: 24),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
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
                  final msg = controller.messages[showLoader ? index - 1 : index];
                  return ChatBubble(message: msg);
                },
              );
            }),
          ),
          const ChatActions(),
        ],
      ),
    );
  }
}
