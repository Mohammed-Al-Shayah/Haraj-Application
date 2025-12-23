import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import '../../../../core/theme/typography.dart';

class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      AppStrings.welcomeMessage,
      style: AppTypography.normal18,
    );
  }
}
