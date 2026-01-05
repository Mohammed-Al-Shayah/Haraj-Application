import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/widgets/main_bar.dart';
import 'package:haraj_adan_app/data/datasources/support_remote_data_source.dart';
import 'package:haraj_adan_app/data/repositories/support_repository_impl.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/assets.dart';
import '../../../../core/theme/strings.dart';
import '../../controllers/support_detail_controller.dart';
import '../widgets/support_actions.dart';
import '../widgets/support_bubble_list.dart';

class SupportDetailScreen extends StatelessWidget {
  const SupportDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? const {};
    final chatId = args['chatId'] as int?;
    final chatName = args['chatName']?.toString() ?? AppStrings.supportTitle;

    if (chatId == null) {
      return Scaffold(
        appBar: MainBar(title: chatName),
        body: const Center(child: Text('Missing support chat id')),
      );
    }

    final controller = Get.put(
      SupportDetailController(
        SupportRepositoryImpl(
          SupportRemoteDataSourceImpl(ApiClient(client: Dio())),
        ),
        chatId: chatId,
        chatName: chatName,
        // useRestFallback: true,
      ),
    );

    return Scaffold(
      appBar: MainBar(
        title: chatName,
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
          Expanded(child: SupportBubbleList(controller: controller)),
          SupportActions(controller: controller),
        ],
      ),
    );
  }
}
