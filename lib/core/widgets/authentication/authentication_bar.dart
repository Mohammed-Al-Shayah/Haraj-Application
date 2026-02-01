import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';
import '../../theme/typography.dart';

class AuthenticationBar extends StatelessWidget {
  final String text;
  final bool showBack;

  const AuthenticationBar({super.key, required this.text, this.showBack = true});

  @override
  Widget build(BuildContext context) {
    final String arrowIcon =
        context.locale.languageCode == 'ar'
            ? AppAssets.arrowRightIcon
            : AppAssets.arrowLeftIcon;
    return SizedBox(
      height: 64.0,
      child: Row(
        children: [
          showBack
              ? GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: SvgPicture.asset(arrowIcon),
              )
              : const SizedBox(width: 24),
          const Spacer(),
          Text(text, style: AppTypography.semiBold16),
          const Spacer(),
        ],
      ),
    );
  }
}
