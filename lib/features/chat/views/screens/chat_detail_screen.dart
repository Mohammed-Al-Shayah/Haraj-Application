import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/data/datasources/chat_detail_remote_data_source.dart';
import '../../../../core/widgets/main_bar.dart';
import '../../../../core/theme/assets.dart';
import '../../../../data/repositories/chat_detail_repository_impl.dart';
import '../../controllers/chat_detail_controller.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_actions.dart';

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? const {};
    final chatId = args['chatId'] as int?;
    final chatName = args['chatName']?.toString() ?? 'Owner Name';
    final otherUserId = args['otherUserId'] as int?;

    if (chatId == null) {
      return Scaffold(
        appBar: MainBar(title: chatName),
        body: const Center(child: Text('Missing chat id')),
      );
    }

    final controller = Get.put(
      ChatDetailController(
        ChatDetailRepositoryImpl(
          ChatDetailRemoteDataSourceImpl(ApiClient(client: Dio())),
        ),
        chatId: chatId,
        chatName: chatName,
        otherUserId: otherUserId,
      ),
    );

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
              final itemCount =
                  controller.messages.length + (showLoader ? 1 : 0);
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
                  final msg =
                      controller.messages[showLoader ? index - 1 : index];
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
