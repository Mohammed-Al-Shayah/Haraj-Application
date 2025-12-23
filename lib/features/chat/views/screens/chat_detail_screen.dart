import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haraj_adan_app/data/datasources/chat_detail_remote_data_source.dart';
import '../../../../core/widgets/main_bar.dart';
import '../../../../core/theme/assets.dart';
import '../../../../data/repositories/chat_detail_repository_impl.dart';
import '../../controllers/chat_detail_controller.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_actions.dart';
import '../widgets/chat_ad_preview.dart';

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ChatDetailController(
        ChatDetailRepositoryImpl(ChatDetailRemoteDataSourceImpl()),
      ),
    );

    return Scaffold(
      appBar: MainBar(
        title: 'Owner Name',
        customActions: [
          IconButton(
            icon: SvgPicture.asset(AppAssets.callIcon, width: 24, height: 24),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const ChatAdPreview(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.messages.length,
                itemBuilder: (_, index) {
                  final msg = controller.messages[index];
                  return ChatBubble(text: msg.text, isSender: msg.isSender);
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
