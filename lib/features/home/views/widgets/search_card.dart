import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/assets.dart';
import '../../../../core/theme/color.dart';
import '../../../../core/theme/strings.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/input_field.dart';

class SearchCard extends StatelessWidget {
  const SearchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 205,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.03 * 255).toInt()),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.startAdvertising, style: AppTypography.bold18),
          const SizedBox(height: 12),
          InputField(
            validator: Validators.validatePublicText,
            hintText: AppStrings.placeLocation,
            prefixIconPath: AppAssets.searchIcon,
            suffixIconColor: AppColors.black75,
            prefixIconColor: AppColors.black75,
            keyboardType: TextInputType.text,
            onTap: () => Get.toNamed(Routes.searchScreen),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            onPressed: () => Get.toNamed(Routes.searchScreen),
            title: AppStrings.search,
          ),
        ],
      ),
    );
  }
}
