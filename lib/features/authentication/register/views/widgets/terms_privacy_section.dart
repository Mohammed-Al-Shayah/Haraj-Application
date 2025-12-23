import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import '../../../../../core/theme/strings.dart';
import '../../../../../core/theme/typography.dart';

class TermsPrivacySection extends StatelessWidget {
  const TermsPrivacySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(AppStrings.termsPrivacyText, style: AppTypography.medium14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {},
              child: Text(
                AppStrings.termsConditions,
                style:
                    AppTypography.medium14.copyWith(color: AppColors.primary),
              ),
            ),
            Text(AppStrings.andText, style: AppTypography.medium14),
            GestureDetector(
              onTap: () {},
              child: Text(
                AppStrings.privacyPolicy,
                style:
                    AppTypography.medium14.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
