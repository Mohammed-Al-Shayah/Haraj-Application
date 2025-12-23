import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/assets.dart';
import '../../../../../core/theme/color.dart';
import '../../../../../core/theme/strings.dart';
import '../../../../../core/theme/typography.dart';
import '../../controllers/onboarding_controller.dart';

class LanguageSelection extends StatelessWidget {
  const LanguageSelection({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.find();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.chooseLanguage,
          style: AppTypography.bold14,
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.gray300,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Obx(() {
            return DropdownButton<String>(
              value: controller.selectedLanguage.value,
              items: [
                DropdownMenuItem(
                  value: 'English',
                  child: Text(AppStrings.english),
                ),
                DropdownMenuItem(
                  value: 'Arabic',
                  child: Text(AppStrings.arabic),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.updateLanguage(value);
                }
              },
              isExpanded: true,
              underline: const SizedBox.shrink(),
              icon: SvgPicture.asset(AppAssets.arrowDownIcon),
            );
          }),
        ),
      ],
    );
  }
}
