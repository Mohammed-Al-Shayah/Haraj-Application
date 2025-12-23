import 'package:flutter/material.dart';
import '../../../../core/theme/assets.dart';
import '../../../../core/theme/strings.dart';
import '../../../../core/widgets/input_field.dart';
import '../../../../core/theme/color.dart';

class SupportSearch extends StatelessWidget {
  const SupportSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return InputField(
      hintText: AppStrings.searchText,
      keyboardType: TextInputType.text,
      prefixIconPath: AppAssets.searchIcon,
      prefixIconColor: AppColors.grey,
    );
  }
}
