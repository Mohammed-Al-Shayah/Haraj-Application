import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import '../../../../../core/theme/assets.dart';
import '../../../../../core/theme/strings.dart';
import '../../../../../core/theme/typography.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../controllers/ad_controller.dart';
import 'appearance_selector.dart';

class AppearanceBottomSheet extends StatelessWidget {
  final AdController controller;

  const AppearanceBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final currentLanguage = LocalizeAndTranslate.getLanguageCode();
    final alignment =
        currentLanguage == 'ar' ? Alignment.centerRight : Alignment.centerLeft;
    RxString tempSelectedAppearance = controller.selectedAppearance.value.obs;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: SvgPicture.asset(
              AppAssets.bottomSheetIndicatorIcon,
              height: 4,
              width: 40,
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: alignment,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppStrings.appearance, style: AppTypography.bold18),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          AppearanceSelector(
            selectedAppearance: tempSelectedAppearance,
            onAppearanceSelected: (value) {
              tempSelectedAppearance.value = value;
            },
          ),
          const SizedBox(height: 20),
          Card(
            color: AppColors.white,
            elevation: 9.0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: PrimaryButton(
                      onPressed: () {
                        tempSelectedAppearance.value = 'On Map';
                        Get.back();
                      },
                      title: AppStrings.clearFilter,
                      backgroundColor: AppColors.gray100,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PrimaryButton(
                      onPressed: () {
                        controller.selectedAppearance.value =
                            tempSelectedAppearance.value;
                        Get.back();
                      },
                      title: AppStrings.apply,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
