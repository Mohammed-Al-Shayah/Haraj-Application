import 'package:flutter/material.dart';
import '../../../../../core/theme/strings.dart';
import '../../../../../core/theme/color.dart';
import '../../../../../core/theme/typography.dart';

class SplashTitle extends StatelessWidget {
  const SplashTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      AppStrings.appTitle,
      style: AppTypography.bold24.copyWith(color: AppColors.white),
    );
  }
}
