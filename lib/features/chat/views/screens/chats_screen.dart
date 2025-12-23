import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/widgets/main_bar.dart';
import 'package:haraj_adan_app/core/widgets/side_menu.dart';
import 'package:haraj_adan_app/data/datasources/chat_remote_datasource.dart';
import '../../../../data/repositories/chat_repository_impl.dart';
import '../../controllers/chat_controller.dart';
import '../../../../core/theme/strings.dart';
import '../widgets/chat_item.dart';
import '../widgets/chat_search.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ChatController(ChatRepositoryImpl(ChatRemoteDataSourceImpl())),
    );

    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: MainBar(
        title: AppStrings.messagesTitle,
        menu: true,
        scaffoldKey: scaffoldKey,
      ),
      drawer: SideMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const ChatSearch(),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: controller.chats.length,
                  itemBuilder:
                      (_, index) => ChatItem(chat: controller.chats[index]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
