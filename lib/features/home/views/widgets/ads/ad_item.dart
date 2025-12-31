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
    final createdLabel = _formatCreatedAt();

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
                      if (createdLabel != null ||
                          (likesCount != null && likesCount! > 0) ||
                          (commentsCount != null && commentsCount! > 0))
                        Row(
                          textDirection: TextDirection.ltr,
                          children: [
                            if (createdLabel != null)
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(AppAssets.timeIcon),
                                      const SizedBox(width: 4),
                                      Text(
                                        createdLabel,
                                        style: AppTypography.normal12.copyWith(
                                          color: AppColors.gray500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              const Spacer(),
                            if ((likesCount != null && likesCount! > 0) ||
                                (commentsCount != null && commentsCount! > 0))
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (likesCount != null &&
                                      likesCount! > 0) ...[
                                    Row(
                                      children: [
                                        SvgPicture.asset(AppAssets.likeIcon),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$likesCount',
                                          style: AppTypography.normal12
                                              .copyWith(
                                                color: AppColors.gray500,
                                              ),
                                        ),
                                      ],
                                    ),
                                    if (commentsCount != null &&
                                        commentsCount! > 0)
                                      const SizedBox(width: 12),
                                  ],
                                  if (commentsCount != null &&
                                      commentsCount! > 0)
                                    Row(
                                      children: [
                                        SvgPicture.asset(AppAssets.commentIcon),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$commentsCount',
                                          style: AppTypography.normal12
                                              .copyWith(
                                                color: AppColors.gray500,
                                              ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
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

  String? _formatCreatedAt() {
    if (createdAt == null) return null;
    final raw = createdAt!.trim();
    if (raw.isEmpty) return null;

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;

    final now = DateTime.now();
    final diff = now.difference(parsed);

    if (diff.inDays >= 30) {
      final months = (diff.inDays / 30).floor();
      return '$months mon';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays} d';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} h';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} m';
    } else {
      return 'just now';
    }
  }
}
