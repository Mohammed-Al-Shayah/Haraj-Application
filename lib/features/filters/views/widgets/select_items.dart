import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import 'package:haraj_adan_app/core/widgets/label.dart';
import '../../../../core/widgets/input_field.dart';

class SelectItemsWidget<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final Function(T?) onChanged;
  final List<T> selectedItems;
  final String? textFieldLabel;
  final TextEditingController? controller;
  final Function(String?)? onTextChanged;

  const SelectItemsWidget({
    super.key,
    required this.title,
    required this.items,
    required this.onChanged,
    required this.selectedItems,
    this.textFieldLabel,
    this.controller,
    this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(text: title),
        Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            ...items.map(
              (i) => SelectItem(
                text: i,
                onChanged: onChanged,
                isSelect: selectedItems.contains(i),
              ),
            ),
            if (textFieldLabel != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(textFieldLabel!, style: AppTypography.bold16),
                  const SizedBox(width: 10),
                  SizedBox(
                    // margin: const EdgeInsets.only(top: 10),
                    width: 80,
                    child: InputField(
                      onChanged: onTextChanged,
                      keyboardType: TextInputType.number,
                      // isRequired: false, keyboardType: TextInputType.number, controller: controller!,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class SelectItem<T> extends StatelessWidget {
  final T text;
  final bool isSelect;
  final Function(T?) onChanged;

  const SelectItem({
    super.key,
    required this.text,
    required this.isSelect,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged.call(text),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelect ? AppColors.primary : AppColors.gray200,
          borderRadius: BorderRadius.circular(5),
        ),
        child:
            ["none", "0", "null"].contains(text.toString().toLowerCase())
                ? Icon(
                  Icons.block,
                  color: isSelect ? AppColors.white : AppColors.black75,
                )
                : Text(
                  text.toString(),
                  style: AppTypography.bold16.copyWith(
                    color: isSelect ? AppColors.white : AppColors.black75,
                  ),
                ),
      ),
    );
  }
}
