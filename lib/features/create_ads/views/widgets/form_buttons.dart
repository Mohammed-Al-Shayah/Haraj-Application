import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/widgets/primary_button.dart';
import 'package:haraj_adan_app/features/create_ads/controllers/create_ads_controller.dart';
import '../../../../core/theme/color.dart';

class FormButtons extends StatelessWidget {
  const FormButtons({
    super.key,
    required this.controller,
    this.onSubmit,
    this.isSubmitting = false,
  });

  final CreateAdsController controller;
  final Future<void> Function()? onSubmit;
  final bool isSubmitting;

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
            showProgress: isSubmitting && controller.currentStep.value == 2,
            onPressed: () async {
              final isLastStep = controller.currentStep.value == 2;
              if (isLastStep) {
                if (isSubmitting) return;
                if (onSubmit != null) {
                  await onSubmit!();
                }
              } else {
                controller.goToNextStep();
              }
            },
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
