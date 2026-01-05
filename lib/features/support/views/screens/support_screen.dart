import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/widgets/main_bar.dart';
import 'package:haraj_adan_app/core/widgets/side_menu.dart';
import 'package:haraj_adan_app/data/datasources/support_remote_data_source.dart';
import 'package:haraj_adan_app/data/repositories/support_repository_impl.dart';
import 'package:haraj_adan_app/features/support/controllers/support_controller.dart';
import '../../../../core/theme/strings.dart';
import '../widgets/support_item.dart';
import '../widgets/support_search.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      SupportController(
        SupportRepositoryImpl(
          SupportRemoteDataSourceImpl(ApiClient(client: Dio())),
        ),
      ),
    );

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
            SupportSearch(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.chats.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return NotificationListener<ScrollNotification>(
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
                      itemCount: controller.chats.length +
                          (controller.isLoadingMore.value ? 1 : 0),
                      itemBuilder: (_, index) {
                        if (index >= controller.chats.length) {
                          return const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        }
                        return SupportItem(support: controller.chats[index]);
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
