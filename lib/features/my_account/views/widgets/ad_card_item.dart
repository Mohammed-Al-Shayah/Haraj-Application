import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import '../../../../core/theme/typography.dart';

class AdCardItem extends StatelessWidget {
  final String? status;
  final int? adId;
  final String imageUrl;
  final String title;
  final String location;
  final String price;
  final String? currencySymbol;
  final double? latitude;
  final double? longitude;
  final VoidCallback? onTap;
  final bool showDivider;
  final VoidCallback? onEdit;
  final VoidCallback? onFeature;

  const AdCardItem({
    super.key,
    this.status,
    this.adId,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.price,
    this.currencySymbol,
    this.latitude,
    this.longitude,
    required this.onTap,
    this.showDivider = true,
    this.onEdit,
    this.onFeature,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(title, style: AppTypography.bold14),
                          const Spacer(),
                          if (status != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    status == 'Published'
                                        ? AppColors.green50
                                        : AppColors.grey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                status ?? '',
                                style: AppTypography.medium10.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          if (status != null) const SizedBox(height: 8),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          SvgPicture.asset(AppAssets.locationIcon),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.normal12.copyWith(
                                color: AppColors.gray500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatPrice(),
                            style: AppTypography.bold12.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      if (latitude != null && longitude != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            SvgPicture.asset(AppAssets.locationIcon),
                            const SizedBox(width: 4),
                            Text(
                              'Lat: ${latitude!.toStringAsFixed(2)}, Long: ${longitude!.toStringAsFixed(2)}',
                              style: AppTypography.normal12.copyWith(
                                color: AppColors.gray500,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (onEdit != null || onFeature != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (onEdit != null)
                              TextButton.icon(
                                onPressed: onEdit,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  foregroundColor: AppColors.primary,
                                  backgroundColor: AppColors.gray100,
                                ),
                                icon: const Icon(Icons.edit, size: 16),
                                label: Text(AppStrings.editAd),
                              ),
                            if (onEdit != null && onFeature != null)
                              const SizedBox(width: 8),
                            if (onFeature != null)
                              TextButton.icon(
                                onPressed: onFeature,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  foregroundColor: AppColors.primary,
                                  backgroundColor: AppColors.gray100,
                                ),
                                icon: const Icon(Icons.star, size: 16),
                                label: Text(AppStrings.featureAd),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: AppColors.gray300, height: 1),
            ),
        ],
      ),
    );
  }

  String _formatPrice() {
    final symbol = currencySymbol?.trim() ?? '';
    if (symbol.isNotEmpty) return '$symbol$price';
    return '\$$price';
  }
}
