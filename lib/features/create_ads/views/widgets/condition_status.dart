import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import 'package:haraj_adan_app/features/create_ads/controllers/create_ads_controller.dart';

class ConditionStatus extends StatelessWidget {
  const ConditionStatus({super.key, required this.controller});

  final CreateAdsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.conditionText, style: AppTypography.bold14),
        const SizedBox(height: 12),
        Row(
          children: [
            SizedBox(
              width: 70,
              height: 35,
              child: GestureDetector(
                onTap:
                    () =>
                        controller.condition.value =
                            AppStrings.conditionStatusNew,
                child: Obx(() {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color:
                          controller.condition.value ==
                                  AppStrings.conditionStatusNew
                              ? AppColors.primary
                              : AppColors.gray200,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      AppStrings.conditionStatusNew,
                      style: AppTypography.medium12.copyWith(
                        color:
                            controller.condition.value ==
                                    AppStrings.conditionStatusNew
                                ? AppColors.white
                                : AppColors.black75,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 70,
              height: 35,
              child: GestureDetector(
                onTap:
                    () =>
                        controller.condition.value =
                            AppStrings.conditionStatusUsed,
                child: Obx(() {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color:
                          controller.condition.value ==
                                  AppStrings.conditionStatusUsed
                              ? AppColors.primary
                              : AppColors.gray200,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      AppStrings.conditionStatusUsed,
                      style: AppTypography.medium12.copyWith(
                        color:
                            controller.condition.value ==
                                    AppStrings.conditionStatusUsed
                                ? AppColors.white
                                : AppColors.black75,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
