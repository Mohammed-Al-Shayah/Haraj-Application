import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import '../../../../../core/theme/color.dart';
import '../../../../../core/theme/typography.dart';

class SortOptionSelector extends StatelessWidget {
  final RxString selectedOption;
  final Function(String) onOptionSelected;

  const SortOptionSelector({
    super.key,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> options = [
      AppStrings.relevance,
      AppStrings.nearest,
      AppStrings.lowestPrice,
      AppStrings.highestPrice,
      AppStrings.descendingByDate,
      AppStrings.ascendingByDate,
      AppStrings.byAddressAZ,
      AppStrings.byAddressZA,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        children: options.map((option) {
          return GestureDetector(
            onTap: () => onOptionSelected(option),
            child: Obx(() {
              final isSelected = selectedOption.value == option;

              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  option,
                  style: AppTypography.normal16.copyWith(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              );
            }),
          );
        }).toList(),
      ),
    );
  }
}
