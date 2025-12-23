import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import 'package:haraj_adan_app/features/filters/models/dropdown_button_model.dart';
import 'package:haraj_adan_app/core/widgets/label.dart';

class DropdownButtonWidget<T> extends StatelessWidget {
  const DropdownButtonWidget({
    super.key,
    this.onChanged,
    this.onTap,
    this.menuMaxHeight,
    this.selectedItem,
    required this.items,
    this.title,
    this.hint,
  });

  final String? title;
  final String? hint;
  final void Function(T?)? onChanged;
  final void Function()? onTap;
  final double? menuMaxHeight;
  final T? selectedItem;
  final List<DropdownButtonModel> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) LabelWidget(text: title!),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray300, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<T>(
            hint:
                hint == null ? null : Text(hint!, style: AppTypography.bold16),
            items:
                items
                    .map(
                      (e) => DropdownMenuItem<T>(
                        value: e.dropValue,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            e.dropText!,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: onChanged,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              size: 30,
              color: AppColors.black75,
            ),
            isExpanded: true,
            underline: const SizedBox(),
            onTap: onTap,
            menuMaxHeight: menuMaxHeight,
            value: selectedItem,
            dropdownColor: AppColors.white,
          ),
        ),
      ],
    );
  }
}

class PopupMenuWidget<T> extends StatelessWidget {
  const PopupMenuWidget({
    super.key,
    this.readOnly = false,
    this.withText = true,
    this.isImage = false,
    this.onChanged,
    this.onTap,
    this.menuMaxHeight,
    this.selectedItem,
    required this.node,
    required this.items,
    this.textColor,
    this.padding = EdgeInsets.zero,
  });

  final bool? readOnly;
  final bool withText;
  final bool isImage;
  final Color? textColor;
  final void Function(T?)? onChanged;
  final void Function()? onTap;
  final FocusNode node;
  final double? menuMaxHeight;
  final EdgeInsets padding;
  final T? selectedItem;
  final List<DropdownButtonModel> items;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) {
        return items
            .map(
              (e) => PopupMenuItem<T>(
                value: e.dropValue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.dropText!,
                      style: Theme.of(context).textTheme.displaySmall!,
                    ),
                    if (e.dropImage != null)
                      Image.asset(e.dropImage!, width: 50),
                  ],
                ),
              ),
            )
            .toList();
      },
      color: Theme.of(context).primaryColorLight,
      surfaceTintColor: Theme.of(context).primaryColorLight,
      onOpened: onTap,
      onSelected: onChanged,
      tooltip: "",
      initialValue: selectedItem,
      child: Container(
        padding: padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (withText)
              Text(
                items
                    .firstWhere((element) => element.dropValue == selectedItem)
                    .dropText!,
                style: Theme.of(context).textTheme.displaySmall!.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(width: 3),
            if (items
                    .firstWhere((element) => element.dropValue == selectedItem)
                    .dropImage !=
                null) ...[
              if (!isImage)
                Icon(
                  Icons.language_outlined,
                  color: Theme.of(context).primaryColorLight,
                  size: 30,
                )
              else
                Image.asset(
                  items
                      .firstWhere(
                        (element) => element.dropValue == selectedItem,
                      )
                      .dropImage!,
                  width: 50,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
