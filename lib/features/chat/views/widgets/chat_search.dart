import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/widgets/input_field.dart';

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
