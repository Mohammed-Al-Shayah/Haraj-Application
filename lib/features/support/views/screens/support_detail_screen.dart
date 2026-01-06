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
          Expanded(child: SupportBubbleList(controller: controller)),
          SupportActions(controller: controller),
        ],
      ),
    );
  }
}
