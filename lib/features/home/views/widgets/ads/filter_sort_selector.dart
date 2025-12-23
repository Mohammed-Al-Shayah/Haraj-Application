import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/theme/assets.dart';
import '../../../../../core/theme/color.dart';
import '../../../../../core/theme/typography.dart';

class FilterSortSelector extends StatelessWidget {
  final String? text;
  final String? assetIcon;
  final VoidCallback onPress;

  const FilterSortSelector({
    super.key,
    this.text,
    this.assetIcon,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        decoration: BoxDecoration(
          color: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
          ).surface.withAlpha((0.3 * 255).toInt()),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (text != null) ...[
              Text(
                text!,
                style: AppTypography.normal12.copyWith(color: AppColors.white),
              ),
              const SizedBox(width: 4),
            ],
            if (assetIcon != null) ...[
              SvgPicture.asset(assetIcon!, height: 16, width: 16),
              const SizedBox(width: 4),
            ] else ...[
              SvgPicture.asset(
                AppAssets.arrowDownIcon,
                height: 16,
                width: 16,
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
