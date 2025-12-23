import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/widgets/primary_button.dart';
import 'package:haraj_adan_app/features/create_ads/controllers/create_ads_controller.dart';
import '../../../../core/theme/color.dart';

class FormButtons extends StatelessWidget {
  const FormButtons({super.key, required this.controller});

  final CreateAdsController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            onPressed: () => controller.goToPreviousStep(),
            title:
                controller.currentStep.value > 1
                    ? AppStrings.previousButtonText
                    : AppStrings.cancelButtonText,
            backgroundColor: AppColors.gray200,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: PrimaryButton(
            onPressed: () => controller.goToNextStep(),
            title:
                controller.currentStep.value == 2
                    ? AppStrings.postButtonText
                    : AppStrings.nextButtonText,
          ),
        ),
      ],
    );
  }
}
