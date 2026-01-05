import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/core/widgets/main_bar.dart';
import 'package:haraj_adan_app/core/widgets/side_menu.dart';
import 'package:haraj_adan_app/data/datasources/support_remote_data_source.dart';
import 'package:haraj_adan_app/data/repositories/support_repository_impl.dart';
import 'package:haraj_adan_app/features/support/controllers/support_controller.dart';
import '../../../../core/theme/strings.dart';
import '../widgets/support_item.dart';
import '../widgets/support_search.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  late final SupportController controller;
  bool _navigatedToChat = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      SupportController(
        SupportRepositoryImpl(
          SupportRemoteDataSourceImpl(ApiClient(client: Dio())),
        ),
      ),
    );

    ever(controller.chats, (_) => _openFirstChatIfReady());
    ever(controller.isLoading, (_) => _openFirstChatIfReady());
  }

  void _openFirstChatIfReady() {
    if (_navigatedToChat) return;
    if (controller.isLoading.value) return;
    if (controller.chats.isEmpty) return;
    final chat = controller.chats.first;
    _navigatedToChat = true;
    Get.offNamed(
      Routes.supportDetailScreen,
      arguments: {'chatId': chat.id, 'chatName': chat.name},
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      appBar: MainBar(
        title: AppStrings.supportTitle,
        menu: true,
        scaffoldKey: scaffoldKey,
      ),
      drawer: SideMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Obx(() {
              if (controller.isLoading.value) {
                return const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (_navigatedToChat) {
                return const SizedBox.shrink();
              }
              return Expanded(
                child: Column(
                  children: [
                    SupportSearch(
                      controller: controller.searchController,
                      onChanged: controller.onSearchChanged,
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification.metrics.pixels >=
                              notification.metrics.maxScrollExtent - 100) {
                            controller.loadMore();
                          }
                          return false;
                        },
                        child: RefreshIndicator(
                          onRefresh: () => controller.loadChats(reset: true),
                          child: ListView.builder(
                            itemCount:
                                controller.chats.length +
                                (controller.isLoadingMore.value ? 1 : 0),
                            itemBuilder: (_, index) {
                              if (index >= controller.chats.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return SupportItem(
                                support: controller.chats[index],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
