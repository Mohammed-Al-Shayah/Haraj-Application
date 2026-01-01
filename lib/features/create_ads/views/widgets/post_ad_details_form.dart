import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/widgets/input_field.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/features/create_ads/controllers/create_ads_controller.dart';
import 'package:haraj_adan_app/features/create_ads/controllers/post_ad_form_controller.dart';
import 'package:haraj_adan_app/features/filters/models/enums.dart';
import 'package:haraj_adan_app/features/filters/views/widgets/select_items.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class PostAdDetailsForm extends StatelessWidget {
  const PostAdDetailsForm({
    super.key,

    required this.controller,

    this.postForm,

    this.adType,

    this.categoryId,

    this.categoryTitle,
  });

  final CreateAdsController controller;

  final PostAdFormController? postForm;

  final AdType? adType;

  final int? categoryId;

  final String? categoryTitle;

  @override
  Widget build(BuildContext context) {
    Widget content() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // Basic info
          InputField(
            controller: controller.titleCtrl,

            keyboardType: TextInputType.text,

            labelText: AppStrings.adNameText,

            hintText: AppStrings.adNameHint,

            onChanged: (v) => postForm?.title.value = v,
          ),

          const SizedBox(height: 20),

          InputField(
            controller: controller.locationCtrl,

            keyboardType: TextInputType.text,

            labelText: AppStrings.locationText,

            hintText: AppStrings.locationText,

            onChanged: (v) => postForm?.address.value = v,
          ),

          const SizedBox(height: 20),

          InputField(
            controller: controller.priceCtrl,

            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],

            labelText: AppStrings.priceText,

            hintText: AppStrings.priceText,

            onChanged: (v) => postForm?.price.value = v,
          ),

          const SizedBox(height: 20),

          InputField(
            controller: controller.descriptionCtrl,

            keyboardType: TextInputType.text,

            labelText: AppStrings.descriptionText,

            hintText: AppStrings.descriptionHint,

            maxLines: 5,

            onChanged: (v) => postForm?.descr.value = v,
          ),

          const SizedBox(height: 15),

          // ConditionStatus(controller: controller),
          const SizedBox(height: 20),

          // Currency (shared for all types)
          Obx(() {
            final specs = controller.adRealEstateSpecs.value;

            final int currentId =
                postForm?.currencyId.value ??
                specs.currencyId ??
                _currencyId(CurrencyOption.rialYemeni);

            final CurrencyOption currentOpt = _currencyFromId(currentId);

            return SelectItemsWidget<CurrencyOption>(
              title: AppStrings.currency,

              items: CurrencyOption.values,

              onChanged: (v) {
                if (v == null) return;

                final int id = _currencyId(v);

                postForm?.currencyId.value = id;

                controller.adRealEstateSpecs.update((val) {
                  val!.currencyId = id;
                });
              },

              selectedItems: [currentOpt],
            );
          }),

          const SizedBox(height: 20),

          // Payment system (shared for all types)
          Obx(() {
            final specs = controller.adRealEstateSpecs.value;

            return SelectItemsWidget<PaySystem>(
              controller: specs.realEstatePartsYears,

              textFieldLabel:
                  specs.paySystem == PaySystem.cash
                      ? null
                      : "${AppStrings.yearCount}: ",

              title: AppStrings.paySystem,

              items: PaySystem.values,

              onChanged: (v) {
                if (v == null) return;

                controller.adRealEstateSpecs.update((val) {
                  val!.paySystem = v;

                  if (v == PaySystem.cash) {
                    val.realEstatePartsYears?.text = "";
                  }
                });
              },

              selectedItems: [specs.paySystem ?? PaySystem.cash],
            );
          }),

          const SizedBox(height: 20),

          if (postForm != null) ...[
            _AttributesSection(form: postForm!),
            const SizedBox(height: 15),
            _FeaturedSection(form: postForm!),
            const SizedBox(height: 15),
          ],
        ],
      );
    }

    if (postForm != null) {
      return Obx(() {
        if (postForm!.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return content();
      });
    }

    return content();
  }

  int _currencyId(CurrencyOption opt) {
    switch (opt) {
      case CurrencyOption.rialYemeni:
        return 1;

      case CurrencyOption.poundEgp:
        return 2;

      case CurrencyOption.dollarUsd:
        return 3;

      case CurrencyOption.euro:
        return 4;
    }
  }

  CurrencyOption _currencyFromId(int id) {
    switch (id) {
      case 2:
        return CurrencyOption.poundEgp;

      case 3:
        return CurrencyOption.dollarUsd;

      case 4:
        return CurrencyOption.euro;

      case 1:
      default:
        return CurrencyOption.rialYemeni;
    }
  }
}

class _AttributesSection extends StatelessWidget {
  const _AttributesSection({required this.form});

  final PostAdFormController form;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final attrs = form.attributesSchema;

      if (attrs.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          for (final attr in attrs) ...[
            _AttributeField(attr: attr as Map, form: form),

            const SizedBox(height: 16),
          ],
        ],
      );
    });
  }
}

class _AttributeField extends StatelessWidget {
  const _AttributeField({required this.attr, required this.form});

  final Map attr;
  final PostAdFormController form;

  @override
  Widget build(BuildContext context) {
    final int id = (attr['id'] as num?)?.toInt() ?? 0;
    final String code =
        (attr['category_attributes_types']?['code'] ?? '').toString();
    final bool isArabic = LocalizeAndTranslate.getLanguageCode()
        .toLowerCase()
        .startsWith('ar');
    final String rawName = (attr['name'] ?? '').toString();
    final String rawNameEn = (attr['name_en'] ?? '').toString();
    final String label =
        isArabic
            ? (rawName.isNotEmpty ? rawName : rawNameEn)
            : (rawNameEn.isNotEmpty ? rawNameEn : rawName);
    final bool requiredAttr = attr['is_required'] == true;
    final List values = (attr['category_attributes_values'] as List?) ?? [];
    int? asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    String valueLabel(Map v) {
      final String n = (v['name'] ?? '').toString();
      final String ne = (v['name_en'] ?? '').toString();
      return isArabic ? (n.isNotEmpty ? n : ne) : (ne.isNotEmpty ? ne : n);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (requiredAttr)
              const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        if (code == 'text' || code == 'number')
          TextFormField(
            initialValue: form.selectedAttributes[id]?.toString(),
            keyboardType:
                code == 'number' ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: label,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 10,
              ),
            ),
            onChanged: (v) => form.selectedAttributes[id] = v,
          )
        else if (code == 'select' || code == 'radio')
          Obx(() {
            final dynamic selectedRaw = form.selectedAttributes[id];
            final int? selectedId = asInt(selectedRaw);
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  values.map((v) {
                    final int valId = asInt(v is Map ? v['id'] : null) ?? 0;
                    final String title =
                        v is Map ? valueLabel(v) : v.toString();
                    final bool isSelected = valId == selectedId;
                    return _pillChip(
                      title: title,
                      isSelected: isSelected,
                      onTap: () => form.selectedAttributes[id] = valId,
                    );
                  }).toList(),
            );
          })
        else if (code == 'checkbox')
          Obx(() {
            final dynamic raw = form.selectedAttributes[id];
            final List<int> current = <int>[];
            if (raw is List) {
              current.addAll(raw.map<int?>(asInt).whereType<int>().toList());
            } else if (raw is int) {
              final v = asInt(raw);
              if (v != null && v > 0) current.add(v);
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  values.map((v) {
                    final int valId = asInt(v is Map ? v['id'] : null) ?? 0;
                    final String title =
                        v is Map ? valueLabel(v) : v.toString();
                    final bool isSelected = current.contains(valId);
                    return _pillChip(
                      title: title,
                      isSelected: isSelected,
                      onTap: () {
                        final updated = List<int>.from(current);
                        if (isSelected) {
                          updated.remove(valId);
                        } else {
                          updated.add(valId);
                        }
                        form.selectedAttributes[id] = updated;
                      },
                    );
                  }).toList(),
            );
          })
        else
          TextFormField(
            initialValue: form.selectedAttributes[id]?.toString(),
            decoration: InputDecoration(
              hintText: label,
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => form.selectedAttributes[id] = v,
          ),
      ],
    );
  }
}

Widget _pillChip({
  required String title,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  const Color selectedColor = Color(0xFF0B5CAB);
  const Color borderColor = Color(0xFFCBD5E1);

  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? selectedColor : borderColor),
        ),
        child: Text(
          title,
          style: AppTypography.bold16.copyWith(
            color: isSelected ? Colors.white : AppColors.black75,
          ),
        ),
      ),
    ),
  );
}

class _FeaturedSection extends StatelessWidget {
  const _FeaturedSection({required this.form});

  final PostAdFormController form;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool enabled = form.isFeaturedEnabled.value;
      final double pricePerDay = form.featuredPricePerDay.value;
      final int defaultDays = form.featuredDefaultDays.value;
      final double wallet = form.walletBalance.value;
      final int? selectedId = form.selectedDiscountId.value;
      final int totalDays = defaultDays + form.selectedDiscountPeriod.value;
      final double finalPrice = form.calculateFeaturedFinalPrice();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('Featured Ad', 'إعلان مميز'),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_t('Default days', 'الأيام الافتراضية')}: $defaultDays    ${_t('Price/day', 'السعر/اليوم')}: ${pricePerDay.toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: Text(
                  '${_t('Wallet', 'المحفظة')}: ${wallet.toStringAsFixed(2)}',
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_t('Promote this ad', 'ترقية الإعلان')),
            subtitle: Text(
              _t(
                'Enable featured ad before submitting',
                'فعّل الإعلان المميز قبل النشر',
              ),
            ),
            value: enabled,
            onChanged: form.setFeaturedEnabled,
          ),
          if (enabled) ...[
            if (form.discounts.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _t('Discounts', 'الخصومات'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    form.discounts.map((d) {
                      if (d is! Map) return const SizedBox.shrink();
                      final int id = (d['id'] as num?)?.toInt() ?? 0;
                      final num pct = d['percentage'] ?? 0;
                      final num period = d['period'] ?? 0;
                      final bool isSelected = id == selectedId;
                      final String label = _t(
                        '${pct.toString()}% for ${period.toString()} days',
                        '${pct.toString()}% لمدة ${period.toString()} يوم',
                      );
                      return ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (v) => form.selectDiscount(v ? d : null),
                      );
                    }).toList(),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(_t('No discounts available', 'لا توجد خصومات متاحة')),
            ],
            const SizedBox(height: 8),
            Text('${_t('Total days', 'إجمالي الأيام')}: $totalDays'),
            Text(
              '${_t('Final price', 'السعر النهائي')}: ${finalPrice.toStringAsFixed(2)}',
            ),
            if (!form.canPayFeatured())
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _t(
                    'Insufficient balance for featured ad',
                    'الرصيد غير كافٍ للإعلان المميز',
                  ),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ],
      );
    });
  }
}

String _t(String en, String ar) {
  final lang = LocalizeAndTranslate.getLanguageCode();
  return lang.startsWith('ar') ? ar : en;
}
