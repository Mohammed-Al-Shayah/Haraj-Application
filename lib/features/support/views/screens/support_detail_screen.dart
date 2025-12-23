import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/widgets/main_bar.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/assets.dart';
import '../../../../core/theme/strings.dart';
import '../widgets/support_actions.dart';
import '../widgets/support_bubble_list.dart';

class SupportDetailScreen extends StatelessWidget {
  const SupportDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainBar(
        title: AppStrings.supportTitle,
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
        children: const [
          Expanded(child: SupportBubbleList()),
          SupportActions(),
        ],
      ),
    );
  }
}
