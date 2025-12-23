import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import '../../../../core/theme/assets.dart';

class SeeAllHeader extends StatelessWidget {
  final VoidCallback onSeeAllPressed;
  final String title;

  const SeeAllHeader({
    super.key,
    required this.onSeeAllPressed,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final currentLanguage = LocalizeAndTranslate.getLanguageCode();
    final arrowIcon =
        currentLanguage == 'en'
            ? AppAssets.arrowRightIcon
            : AppAssets.arrowLeftIcon;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.bold16,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: onSeeAllPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.seeAll,
                style: AppTypography.medium14.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              SvgPicture.asset(
                arrowIcon,
                height: 16,
                width: 16,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
