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
    final selected = Set<T>.from(selectedItems);

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
              (i) => _SelectItem(
                text: i,
                isSelect: selected.contains(i),
                onTap: () => onChanged.call(i),
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
                    width: 80,
                    child: InputField(
                      onChanged: onTextChanged,
                      keyboardType: TextInputType.number,
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

class _SelectItem<T> extends StatelessWidget {
  final T text;
  final bool isSelect;
  final VoidCallback onTap;

  const _SelectItem({
    required this.text,
    required this.isSelect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const selectedColor = Color(0xFF0B5CAB); // darker blue highlight
    const borderColor = Color(0xFFCBD5E1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelect ? selectedColor : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelect ? selectedColor : borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child:
              ["none", "0", "null"].contains(text.toString().toLowerCase())
                  ? Icon(
                    Icons.block,
                    color: isSelect ? Colors.white : AppColors.black75,
                  )
                  : Text(
                    text.toString(),
                    style: AppTypography.bold16.copyWith(
                      color: isSelect ? Colors.white : AppColors.black75,
                    ),
                  ),
        ),
      ),
    );
  }
}
