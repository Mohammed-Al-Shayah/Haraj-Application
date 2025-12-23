import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/features/create_ads/controllers/create_ads_controller.dart';
import 'package:haraj_adan_app/features/create_ads/views/widgets/steps_circle.dart';

class StepsSection extends StatelessWidget {
  const StepsSection({super.key, required this.controller});

  final CreateAdsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            StepsCircle(step: 1, isActive: controller.currentStep.value >= 1),
            StepsCircle(step: 2, isActive: controller.currentStep.value >= 2),
          ],
        ),
      ),
    );
  }
}
