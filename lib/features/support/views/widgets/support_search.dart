import 'package:flutter/material.dart';
import '../../../../core/theme/assets.dart';
import '../../../../core/theme/strings.dart';
import '../../../../core/widgets/input_field.dart';
import '../../../../core/theme/color.dart';

class SupportSearch extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const SupportSearch({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InputField(
      hintText: AppStrings.searchText,
      keyboardType: TextInputType.text,
      prefixIconPath: AppAssets.searchIcon,
      prefixIconColor: AppColors.grey,
      controller: controller,
      onChanged: onChanged,
    );
  }
}
