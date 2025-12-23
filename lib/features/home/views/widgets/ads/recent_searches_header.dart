import 'package:flutter/material.dart';
import '../../../../../core/theme/color.dart';
import '../../../../../core/theme/strings.dart';
import '../../../../../core/theme/typography.dart';

class RecentSearchesHeader extends StatelessWidget {
  const RecentSearchesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppStrings.recentSearches,
              style: AppTypography.bold16,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.clearAll,
                  style: AppTypography.medium14.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
