import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import '../../../../../core/routes/routes.dart';
import '../../../../../core/theme/color.dart';
import '../../../../../core/theme/typography.dart';
import '../../../../../core/widgets/primary_button.dart';
import 'language_selection.dart';

class BottomBox extends StatelessWidget {
  const BottomBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 310,
      width: double.infinity,
      decoration: const BoxDecoration(color: AppColors.white),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.welcomeMessage, style: AppTypography.bold24),
            const SizedBox(height: 12),
            Text(AppStrings.exploreMessage, style: AppTypography.normal16),
            const SizedBox(height: 20),
            const LanguageSelection(),
            const SizedBox(height: 20),
            PrimaryButton(
              onPressed: () => Get.toNamed(Routes.loginScreen),
              title: AppStrings.getStarted,
            ),
          ],
        ),
      ),
    );
  }
}
