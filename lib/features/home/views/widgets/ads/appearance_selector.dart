import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import '../../../../../core/theme/color.dart';
import '../../../../../core/theme/typography.dart';

class AppearanceSelector extends StatelessWidget {
  final RxString selectedAppearance;
  final Function(String) onAppearanceSelected;

  const AppearanceSelector({
    super.key,
    required this.selectedAppearance,
    required this.onAppearanceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => onAppearanceSelected('List'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Obx(() {
                    return Container(
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selectedAppearance.value == 'List'
                            ? AppColors.primary
                            : AppColors.transparent,
                        border: Border.all(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 8.0),
                  Text(AppStrings.list, style: AppTypography.normal16),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onAppearanceSelected('On Map'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Obx(() {
                    return Container(
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selectedAppearance.value == 'On Map'
                            ? AppColors.primary
                            : AppColors.transparent,
                        border: Border.all(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 8.0),
                  Text(AppStrings.onMap, style: AppTypography.normal16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
