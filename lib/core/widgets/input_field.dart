import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../routes/routes.dart';
import '../theme/assets.dart';
import '../theme/color.dart';
import '../theme/strings.dart';
import '../theme/typography.dart';

class InputField extends StatelessWidget {
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final void Function()? onTap;
  final void Function()? onEditingComplete;
  final VoidCallback? togglePasswordVisibility;
  final String? labelText;
  final String? hintText;
  final bool isPassword;
  final bool? isResetPassword;
  final bool isPasswordVisible;
  final String? prefixIconPath;
  final String? suffixIconPath1;
  final String? suffixIconPath2;
  final int? maxLines;
  final bool? readOnly;
  final bool isOptional;
  final bool enabled;
  final bool autoFocus;
  final FocusNode? node;
  final Color? fillColor;
  final Color? textColor;
  final Color? hintStyleColor;
  final Color? prefixIconColor;
  final Color? suffixIconColor;
  final Color? enabledBorderColor;
  final List<TextInputFormatter>? inputFormatters;

  const InputField({
    super.key,
    required this.keyboardType,
    this.controller,
    this.onChanged,
    this.validator,
    this.onTap,
    this.onEditingComplete,
    this.togglePasswordVisibility,
    this.labelText,
    this.hintText,
    this.isPassword = false,
    this.isResetPassword = false,
    this.isPasswordVisible = false,
    this.prefixIconPath,
    this.suffixIconPath1,
    this.suffixIconPath2,
    this.maxLines,
    this.readOnly = false,
    this.isOptional = false,
    this.enabled = true,
    this.autoFocus = false,
    this.node,
    this.fillColor,
    this.textColor,
    this.hintStyleColor,
    this.prefixIconColor,
    this.suffixIconColor,
    this.enabledBorderColor,
    this.inputFormatters,
  });

  Widget _buildSuffixIcon(bool isPasswordVisible) {
    if (isPassword) {
      return GestureDetector(
        onTap: togglePasswordVisibility,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SvgPicture.asset(
            isPasswordVisible
                ? AppAssets.passwordShowIcon
                : AppAssets.passwordHideIcon,
            width: 10.0,
            height: 10.0,
            colorFilter:
                suffixIconColor != null
                    ? ColorFilter.mode(suffixIconColor!, BlendMode.srcIn)
                    : null,
          ),
        ),
      );
    } else if (suffixIconPath1 != null || suffixIconPath2 != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (suffixIconPath1 != null)
            SvgPicture.asset(
              suffixIconPath1!,
              width: 32,
              height: 32,
              colorFilter:
                  suffixIconColor != null
                      ? ColorFilter.mode(suffixIconColor!, BlendMode.srcIn)
                      : null,
            ),
          if (suffixIconPath2 != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SvgPicture.asset(
                suffixIconPath2!,
                width: 32,
                height: 32,
                colorFilter:
                    suffixIconColor != null
                        ? ColorFilter.mode(suffixIconColor!, BlendMode.srcIn)
                        : null,
              ),
            ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget? _buildPrefixIcon() {
    if (prefixIconPath != null) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          child: SvgPicture.asset(
            prefixIconPath!,
            colorFilter:
                prefixIconColor != null
                    ? ColorFilter.mode(prefixIconColor!, BlendMode.srcIn)
                    : null,
          ),
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final textScale =
        MediaQuery.textScaleFactorOf(context).clamp(1.0, 1.4).toDouble();
    final labelSpacing = textScale > 1.2 ? 6.0 : 8.0;
    final verticalPadding = textScale > 1.2 ? 10.0 : 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null)
          Padding(
            padding: EdgeInsets.only(bottom: labelSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(labelText!, style: AppTypography.bold14),
                if (isPassword && !isResetPassword!)
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.forgotPasswordScreen),
                    child: Text(
                      AppStrings.forgotPasswordQuestionsMark,
                      style: AppTypography.bold14.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          obscureText: isPassword && !isPasswordVisible,
          maxLines: isPassword ? 1 : maxLines,
          readOnly: readOnly ?? false,
          autofocus: autoFocus,
          onTapOutside: (v) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          enabled: enabled,
          focusNode: node,
          onTap: onTap,
          decoration: InputDecoration(
            prefixIcon: _buildPrefixIcon(),
            suffixIcon: _buildSuffixIcon(isPasswordVisible),
            hintText: hintText,
            hintStyle: TextStyle(color: hintStyleColor ?? AppColors.gray400),
            filled: true,
            fillColor:
                fillColor ??
                ColorScheme.fromSeed(seedColor: AppColors.primary).surface,
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.primary),
              borderRadius: BorderRadius.circular(8.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: enabledBorderColor ?? AppColors.gray300,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(10.0),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(10.0),
            ),
            errorStyle: const TextStyle(color: Colors.red),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: 10.0,
            ),
          ),
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: TextStyle(color: textColor ?? AppColors.black75),
        ),
      ],
    );
  }
}
