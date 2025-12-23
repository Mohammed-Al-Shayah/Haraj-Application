import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import 'package:haraj_adan_app/core/widgets/primary_button.dart';

class SuccessPostedScreen extends StatelessWidget {
  const SuccessPostedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: 500,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(child: SvgPicture.asset(AppAssets.successIcon)),
                    const SizedBox(height: 20),
                    Text(AppStrings.thankYouText, style: AppTypography.bold20),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.postUnderReviewText,
                      style: AppTypography.medium14,
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      onPressed: () => Get.offNamed(Routes.homeScreen),
                      title: AppStrings.homeButtonText,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
