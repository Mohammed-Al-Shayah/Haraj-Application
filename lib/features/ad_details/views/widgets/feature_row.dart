import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/color.dart';

import '../../../../core/theme/typography.dart';

class FeatureRow extends StatelessWidget {
  final String label;
  final String value;

  const FeatureRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.normal14.copyWith(color: AppColors.black75),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.normal12.copyWith(color: AppColors.black75),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
