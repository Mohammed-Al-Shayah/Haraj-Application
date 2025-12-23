import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import 'package:haraj_adan_app/core/widgets/label.dart';
import '../../../../core/widgets/input_field.dart';

class FromToField extends StatelessWidget {
  final TextEditingController from;
  final TextEditingController to;
  final String? title;

  const FromToField(
      {super.key, required this.from, required this.to, this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) LabelWidget(text: title!),
        Row(
          children: [
            Expanded(
                child: InputField(
              keyboardType: TextInputType.number,
              controller: from,
              hintText: AppStrings.from,
            )),
            const SizedBox(
              width: 10,
            ),
            Text(
              AppStrings.to,
              style: AppTypography.bold16,
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
                child: InputField(
              keyboardType: TextInputType.number,
              controller: to,
              hintText: AppStrings.to,
            )),
          ],
        ),
      ],
    );
  }
}
