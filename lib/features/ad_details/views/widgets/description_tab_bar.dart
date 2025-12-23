import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/features/ad_details/controllers/ad_details_controller.dart';

class DescriptionTabBar extends StatelessWidget {
  const DescriptionTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdDetailsController>();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Obx(() {
        final ad = controller.ad.value;
        final desc = ad?.description ?? AppStrings.descriptionText;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.descriptionText, style: AppTypography.bold16),
            const SizedBox(height: 16.0),
            Text(
              desc,
              style: AppTypography.normal14.copyWith(color: AppColors.black75),
            ),
          ],
        );
      }),
    );
  }
}
