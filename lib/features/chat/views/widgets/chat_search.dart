import 'package:flutter/material.dart';
import '../../../../core/theme/assets.dart';
import '../../../../core/theme/strings.dart';
import '../../../../core/widgets/input_field.dart';
import '../../../../core/theme/color.dart';

class ChatSearch extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const ChatSearch({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputField(
      hintText: AppStrings.searchText,
      keyboardType: TextInputType.text,
      controller: controller,
      onChanged: onChanged,
      prefixIconPath: AppAssets.searchIcon,
      prefixIconColor: AppColors.grey,
    );
  }
}
