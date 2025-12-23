import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/shimmer_loading.dart';

class FeaturedAdItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final bool isLoading;
  final VoidCallback onTap;
  final int index;
  final bool isFavourite;

  const FeaturedAdItem({
    super.key,
    required this.imageUrl,
    required this.title,
    this.isLoading = false,
    required this.onTap,
    required this.index,
    this.isFavourite = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const ShimmerLoading(width: double.infinity, height: 120),
          ),
          const SizedBox(height: 8),
          const ShimmerLoading(width: double.infinity, height: 16),
        ],
      );
    }

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Center(
                    child: Image.asset(
                      AppAssets.loadingIcon,
                      width: 60,
                      height: 60,
                    ),
                  ),
                  if (imageUrl.isNotEmpty)
                    Positioned.fill(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, _, _) => const Icon(Icons.broken_image),
                      ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.white75,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavourite ? Icons.favorite : Icons.favorite_border,
                        color: isFavourite ? AppColors.red : AppColors.gray300,
                        size: 18,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppStrings.featured,
                        style: AppTypography.normal12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(title, style: AppTypography.normal14),
            ),
          ),
        ],
      ),
    );
  }
}
