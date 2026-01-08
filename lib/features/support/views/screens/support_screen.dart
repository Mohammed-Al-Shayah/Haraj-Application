import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/widgets/main_bar.dart';
import 'package:haraj_adan_app/core/widgets/side_menu.dart';
import 'package:haraj_adan_app/features/support/controllers/support_controller.dart';
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
    controller = Get.find<SupportController>();

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
    final scaffoldKey = GlobalKey<ScaffoldState>();

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
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_navigatedToChat) return const SizedBox.shrink();

          return Column(
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
                    child:
                        controller.chats.isEmpty
                            ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              children: [
                                SizedBox(
                                  height: 200,
                                  child: _buildEmptyState(context),
                                ),
                              ],
                            )
                            : ListView.builder(
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
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.support_agent, size: 54, color: theme.colorScheme.primary),
        const SizedBox(height: 20),
        Text(
          AppStrings.supportEmptyTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          AppStrings.supportEmptyMessage,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}
