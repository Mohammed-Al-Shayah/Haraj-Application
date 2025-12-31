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
    final textScale =
        MediaQuery.textScaleFactorOf(context).clamp(1.0, 1.4).toDouble();
    final verticalPadding = textScale > 1.2 ? 16.0 : 20.0;
    final betweenFields = textScale > 1.2 ? 10.0 : 12.0;
    final buttonSpacing = textScale > 1.2 ? 12.0 : 16.0;
    final buttonHeight = textScale > 1.2 ? 50.0 : 55.0;

    return Container(
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
      padding: EdgeInsets.all(verticalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.startAdvertising, style: AppTypography.bold18),
          SizedBox(height: betweenFields),
          InputField(
            validator: Validators.validatePublicText,
            hintText: AppStrings.placeLocation,
            prefixIconPath: AppAssets.searchIcon,
            suffixIconColor: AppColors.black75,
            prefixIconColor: AppColors.black75,
            keyboardType: TextInputType.text,
            onTap: () => Get.toNamed(Routes.searchScreen),
          ),
          SizedBox(height: buttonSpacing),
          PrimaryButton(
            onPressed: () => Get.toNamed(Routes.searchScreen),
            title: AppStrings.search,
            minimumSize: Size(double.infinity, buttonHeight),
          ),
        ],
      ),
    );
  }
}
