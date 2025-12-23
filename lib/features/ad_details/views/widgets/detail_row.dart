import 'package:flutter/material.dart';
import '../../../../core/theme/typography.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueTextColor;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTypography.normal14),
              Text(
                value,
                style: AppTypography.normal14.copyWith(
                  color: valueTextColor,
                ),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}
