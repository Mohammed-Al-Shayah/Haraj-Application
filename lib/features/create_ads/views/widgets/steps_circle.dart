import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';

class StepsCircle extends StatelessWidget {
  const StepsCircle({super.key, required this.step, required this.isActive});

  final int step;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: isActive ? AppColors.primary : AppColors.gray200,
          child: Text(
            '$step',
            style: AppTypography.medium12.copyWith(
              color: isActive ? AppColors.white : AppColors.black75,
            ),
          ),
        ),
        SizedBox(width: 10),
        Text(
          [
            AppStrings.detailsStepText,
            AppStrings.featuresStepText,
            AppStrings.photosStepText,
          ][step - 1],
          style: AppTypography.medium12,
        ),
      ],
    );
  }
}
