import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import 'package:haraj_adan_app/core/widgets/label.dart';
import 'package:haraj_adan_app/core/widgets/primary_button.dart';
import 'package:haraj_adan_app/data/models/search_filter_models.dart';
import 'package:haraj_adan_app/features/filters/controllers/search_filter_sheet_controller.dart';
import 'package:haraj_adan_app/features/filters/views/screens/filter_template.dart';
import 'package:haraj_adan_app/features/filters/views/widgets/from_to_field.dart';
import 'package:haraj_adan_app/features/home/controllers/ad_controller.dart';
import 'package:localize_and_translate/localize_and_translate.dart' as loc;

class DynamicCategoryFilter extends StatelessWidget {
  const DynamicCategoryFilter({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
    required this.adController,
    this.onApply,
  });

  final int categoryId;
  final String categoryTitle;
  final AdController adController;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height - 100;
    final controllerTag = 'dynamic_filter_$categoryId';
    final controller =
        Get.isRegistered<SearchFilterSheetController>(tag: controllerTag)
            ? Get.find<SearchFilterSheetController>(tag: controllerTag)
            : Get.put<SearchFilterSheetController>(
              SearchFilterSheetController(
                categoryId: categoryId,
                categoryTitle: categoryTitle,
                adController: adController,
              ),
              tag: controllerTag,
            );

    return SizedBox(
      height: height,
      child: Obx(
        () => FilterTemplate(
          onApplyFilter: () {
            Get.back();
            controller.applyFilters();
            onApply?.call();
          },
          onResetFilter: controller.resetAndApply,
          child: _buildBody(controller),
        ),
      ),
    );
  }

  Widget _buildBody(SearchFilterSheetController controller) {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage.value != null) {
      return _ErrorState(onRetry: controller.retry);
    }

    final category = controller.selectedCategory.value;
    if (category == null) {
      return Center(
        child: Text(AppStrings.categoryNotFound, style: AppTypography.bold16),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CategoryHeader(
              categories: controller.categories,
              selectedId: category.id,
              onSelect: controller.selectCategory,
              title: categoryTitle,
            ),
            const SizedBox(height: 20),
            LabelWidget(text: AppStrings.priceText),
            const SizedBox(height: 10),
            FromToField(
              from: controller.minPriceController,
              to: controller.maxPriceController,
            ),
            const SizedBox(height: 16),
            if (controller.currencies.isNotEmpty) ...[
              LabelWidget(text: AppStrings.currency),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    controller.currencies.map((currency) {
                      final isSelected =
                          controller.selectedCurrencyId.value == currency.id;
                      return RawChip(
                        label: Text(
                          _localizedLabel(currency.name, currency.nameEn),
                          style: TextStyle(
                            color:
                                isSelected
                                    ? AppColors.white
                                    : AppColors.gray700,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        onSelected:
                            (_) =>
                                controller.selectedCurrencyId.value =
                                    currency.id,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.gray100,
                        side: BorderSide(
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : AppColors.gray200,
                        ),
                        checkmarkColor: Colors.transparent,
                        showCheckmark: false,
                      );
                    }).toList(),
              ),
              const SizedBox(height: 20),
            ],
            ...category.attributes.map(
              (attr) => _AttributeSection(
                attribute: attr,
                selectedValues: controller.selectedValues,
                onToggle: controller.toggleValue,
                controllerFor: controller.controllerForAttribute,
                onTextChanged:
                    (id, value) => controller.selectedValues[id] = value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
    required this.title,
  });

  final List<FilterCategoryModel> categories;
  final int selectedId;
  final void Function(int) onSelect;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (categories.length <= 1) {
      return Text(
        title.isNotEmpty ? title : AppStrings.filter,
        style: AppTypography.bold18,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.category, style: AppTypography.bold16),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              categories.map((category) {
                final isSelected = category.id == selectedId;
                final label = _localizedLabel(category.name, category.nameEn);
                return RawChip(
                  label: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? AppColors.white : AppColors.gray700,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) => onSelect(category.id),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.gray100,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.gray200,
                  ),
                  checkmarkColor: Colors.transparent,
                  showCheckmark: false,
                );
              }).toList(),
        ),
      ],
    );
  }
}

class _AttributeSection extends StatelessWidget {
  const _AttributeSection({
    required this.attribute,
    required this.selectedValues,
    required this.onToggle,
    required this.controllerFor,
    required this.onTextChanged,
  });

  final CategoryAttributeModel attribute;
  final RxMap<int, dynamic> selectedValues;
  final void Function(CategoryAttributeModel, CategoryAttributeValueModel)
  onToggle;
  final TextEditingController Function(int) controllerFor;
  final void Function(int, String) onTextChanged;

  @override
  Widget build(BuildContext context) {
    final type = attribute.typeCode.toLowerCase().trim();
    final isCheckbox = type == 'checkbox';

    return Obx(() {
      final selected = selectedValues[attribute.id];

      if (type == 'input' || type == 'number') {
        final controller = controllerFor(attribute.id);
        if (selected is String && controller.text != selected) {
          controller.text = selected;
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _localizedLabel(attribute.name, attribute.nameEn),
                style: AppTypography.bold16,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                keyboardType:
                    type == 'number'
                        ? TextInputType.number
                        : TextInputType.text,
                decoration: InputDecoration(
                  hintText: _localizedLabel(attribute.name, attribute.nameEn),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                onChanged: (val) => onTextChanged(attribute.id, val),
              ),
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _localizedLabel(attribute.name, attribute.nameEn),
              style: AppTypography.bold16,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  attribute.values.map((value) {
                    final label = _localizedLabel(value.name, value.nameEn);
                    final bool isSelected =
                        isCheckbox
                            ? (selected is Set<int> &&
                                selected.contains(value.id))
                            : selected == value.id;
                    return RawChip(
                      label: Text(
                        label,
                        style: TextStyle(
                          color:
                              isSelected ? AppColors.white : AppColors.gray700,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) => onToggle(attribute, value),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.gray100,
                      side: BorderSide(
                        color:
                            isSelected ? AppColors.primary : AppColors.gray200,
                      ),
                      checkmarkColor: Colors.transparent,
                      showCheckmark: false,
                    );
                  }).toList(),
            ),
          ],
        ),
      );
    });
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.errorTitle,
              style: AppTypography.bold18.copyWith(color: AppColors.black75),
            ),
            const SizedBox(height: 8),
            Text(
              'Something went wrong while loading filters.',
              style: AppTypography.bold14.copyWith(color: AppColors.black75),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            PrimaryButton(onPressed: onRetry, title: 'Retry'),
          ],
        ),
      ),
    );
  }
}

String _localizedLabel(String name, String? nameEn) {
  final isEn = loc.LocalizeAndTranslate.getLanguageCode() == 'en';
  final primary = isEn ? (nameEn ?? '') : name;
  final fallback = isEn ? name : (nameEn ?? '');
  if (primary.trim().isNotEmpty) return primary;
  if (fallback.trim().isNotEmpty) return fallback;
  return '';
}
