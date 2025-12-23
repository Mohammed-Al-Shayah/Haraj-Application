import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';

class LabelWidget extends StatelessWidget {
  final String text;

  const LabelWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$text :",
          style: AppTypography.bold16.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
