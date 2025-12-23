import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/theme/assets.dart';
import '../../../../../core/theme/typography.dart';

class RecentItem extends StatelessWidget {
  final String text;
  final VoidCallback onPress;

  const RecentItem({super.key, required this.text, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
      child: GestureDetector(
        onTap: onPress,
        child: Row(
          children: [
            SvgPicture.asset(AppAssets.recentlyIcon),
            const SizedBox(width: 12),
            Text(text, style: AppTypography.normal14),
          ],
        ),
      ),
    );
  }
}
