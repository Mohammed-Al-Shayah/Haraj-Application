import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import '../../../../../core/theme/typography.dart';

class VerificationMessage extends StatelessWidget {
  final String mobile;

  const VerificationMessage({super.key, required this.mobile});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
        children: [
          TextSpan(text: AppStrings.verificationMessage),
          TextSpan(text: mobile, style: AppTypography.bold14),
        ],
      ),
    );
  }
}
