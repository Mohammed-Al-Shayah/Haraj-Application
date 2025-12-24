import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import '../../../../../core/theme/typography.dart';

class AdItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final double price;
  final String? currencySymbol;
  final int? likesCount;
  final int? commentsCount;
  final String? createdAt;
  final double? latitude;
  final double? longitude;
  final VoidCallback? onTap;
  final bool showDivider;

  const AdItem({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.price,
    this.currencySymbol,
    this.likesCount,
    this.commentsCount,
    this.createdAt,
    this.latitude,
    this.longitude,
    required this.onTap,
    this.showDivider = true,
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
                      if (createdAt != null ||
                          likesCount != null ||
                          commentsCount != null)
                        Row(
                          children: [
                            if (createdAt != null) ...[
                              SvgPicture.asset(AppAssets.timeIcon),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  createdAt!,
                                  style: AppTypography.normal12.copyWith(
                                    color: AppColors.gray500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            if (likesCount != null) ...[
                              Row(
                                children: [
                                  SvgPicture.asset(AppAssets.likeIcon),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$likesCount',
                                    style: AppTypography.normal12.copyWith(
                                      color: AppColors.gray500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                            ],
                            if (commentsCount != null) ...[
                              Row(
                                children: [
                                  SvgPicture.asset(AppAssets.commentIcon),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$commentsCount',
                                    style: AppTypography.normal12.copyWith(
                                      color: AppColors.gray500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      const SizedBox(height: 8),
                      Text(title, style: AppTypography.bold14),
                      const SizedBox(height: 8),
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
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${currencySymbol ?? '\$'}$price',
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (showDivider) const Divider(color: AppColors.gray300, height: 1),
        ],
      ),
    );
  }
}
