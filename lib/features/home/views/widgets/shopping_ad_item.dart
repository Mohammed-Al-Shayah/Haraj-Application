import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import '../../../../core/theme/assets.dart';
import '../../../../core/widgets/shimmer_loading.dart';

class ShoppingAdItem extends StatelessWidget {
  final String imageAsset;
  final String name;
  final String location;
  final double price;
  final bool isLoading;
  final VoidCallback? onTap;

  const ShoppingAdItem({
    super.key,
    required this.imageAsset,
    required this.name,
    required this.location,
    required this.price,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 335),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black75.withAlpha((0.03 * 255).toInt()),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: buildContent(),
        ),
      ),
    );
  }

  Widget buildContent() {
    if (isLoading) {
      return Row(
        children: [
          const ShimmerLoading(
            width: 70,
            height: 70,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerLoading(width: 120, height: 16),
                SizedBox(height: 8),
                ShimmerLoading(width: 100, height: 14),
                SizedBox(height: 8),
                ShimmerLoading(width: 60, height: 14),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                AppAssets.loadingIcon,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
              Image.network(
                imageAsset,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTypography.bold14,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  SvgPicture.asset(AppAssets.locationIcon),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location,
                      style: AppTypography.normal12.copyWith(
                        color: AppColors.gray500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '\$$price',
                style: AppTypography.bold12.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
