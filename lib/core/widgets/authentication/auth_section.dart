import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/features/authentication/email_verification/controllers/verification_controller.dart';
import '../../routes/routes.dart';
import '../../theme/typography.dart';

class AuthSection extends StatelessWidget {
  final bool isRegister;
  final bool resendCode;

  const AuthSection({
    super.key,
    required this.isRegister,
    this.resendCode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (resendCode)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppStrings.didNotReceiveCode, style: AppTypography.medium14),
              GestureDetector(
                onTap: () => Get.find<VerificationController>().resendOtp(),
                child: Text(
                  AppStrings.resend,
                  style: AppTypography.medium14.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        if (!resendCode) ...[
          if (isRegister)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.alreadyHaveAccount,
                  style: AppTypography.medium14,
                ),
                GestureDetector(
                  onTap: () => Get.toNamed(Routes.loginScreen),
                  child: Text(
                    AppStrings.logIn,
                    style: AppTypography.medium14.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          if (!isRegister)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppStrings.doNotHaveAccount),
                GestureDetector(
                  onTap: () => Get.toNamed(Routes.registerScreen),
                  child: Text(
                    AppStrings.register,
                    style: AppTypography.medium14.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ],
    );
  }
}
