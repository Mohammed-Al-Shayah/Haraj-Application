import 'package:flutter/material.dart';
import '../../theme/color.dart';
import '../../theme/strings.dart';
import '../../theme/typography.dart';

class OrSeparator extends StatelessWidget {
  const OrSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.gray300, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            AppStrings.orText,
            style: AppTypography.medium10.copyWith(color: AppColors.gray400),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.gray300, thickness: 1)),
      ],
    );
  }
}
