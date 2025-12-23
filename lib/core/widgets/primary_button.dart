import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/color.dart';

class PrimaryButton extends StatelessWidget {
  final Function()? onPressed;
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final double elevation;
  final Size minimumSize;
  final BorderRadius borderRadius;
  final bool showProgress;
  final Color? borderColor;
  final double? borderWidth;
  final bool isActive;

  final String? leadingIcon;
  final String? trailingIcon;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.backgroundColor = AppColors.secondary,
    this.textColor = AppColors.black75,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.bold,
    this.elevation = 0.0,
    this.minimumSize = const Size(double.infinity, 55),
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.showProgress = false,
    this.borderColor,
    this.borderWidth,
    this.isActive = true,
    this.leadingIcon,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isActive && !showProgress ? onPressed : null,
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(elevation),
        minimumSize: WidgetStateProperty.all(minimumSize),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: BorderSide(
              color: borderColor ?? Colors.transparent,
              width: borderWidth ?? 0.0,
            ),
          ),
        ),
        backgroundColor: WidgetStateProperty.all<Color>(
          isActive
              ? backgroundColor
              : backgroundColor.withAlpha((0.5 * 255).toInt()),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Visibility(
            visible: !showProgress,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leadingIcon != null) ...[
                  SvgPicture.asset(
                    leadingIcon!,
                    height: 20,
                    width: 20,
                    colorFilter: ColorFilter.mode(
                      isActive
                          ? textColor
                          : textColor.withAlpha((0.5 * 255).toInt()),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    color:
                        isActive
                            ? textColor
                            : textColor.withAlpha((0.5 * 255).toInt()),
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    trailingIcon!,
                    height: 20,
                    width: 20,
                    colorFilter: ColorFilter.mode(
                      isActive
                          ? textColor
                          : textColor.withAlpha((0.5 * 255).toInt()),
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Visibility(
            visible: showProgress,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
        ],
      ),
    );
  }
}
