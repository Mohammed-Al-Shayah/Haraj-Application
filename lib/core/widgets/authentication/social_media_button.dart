import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/color.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import '../../theme/typography.dart';

class SocialMediaButton extends StatelessWidget {
  final String iconPath;
  final String? text;
  final VoidCallback onPress;

  const SocialMediaButton({
    required this.iconPath,
    this.text,
    required this.onPress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.locale.languageCode == 'ar';

    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: text == null ? MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          children: [
            if (text != null && isArabic) Text(text!, style: AppTypography.semiBold14),
            if (text != null && isArabic) const SizedBox(width: 8),
            SvgPicture.asset(iconPath, width: 24, height: 24),
            if (text != null && !isArabic) const SizedBox(width: 8),
            if (text != null && !isArabic) Text(text!, style: AppTypography.semiBold14),
          ],
        ),
      ),
    );
  }
}
