import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/features/ad_details/controllers/ad_details_controller.dart';
import 'package:haraj_adan_app/features/ad_details/models/ad_details_model.dart';
import 'package:haraj_adan_app/features/ad_details/views/widgets/detail_row.dart';
import 'package:haraj_adan_app/features/ad_details/views/widgets/features_section.dart';
import 'package:haraj_adan_app/features/ad_details/views/widgets/questions_section.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class AdDetailsTabBar extends StatelessWidget {
  const AdDetailsTabBar({super.key});

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${(date.year % 100).toString().padLeft(2, '0')}';
  }

  List<MapEntry<AdAttributeModel, String>> _filterAttributes(
    List<AdAttributeModel> attrs,
    bool isEn,
  ) {
    return attrs
        .map((a) {
          final value = a.displayValue(isEn);
          if (value.isEmpty || value == '-') return null;
          return MapEntry(a, value);
        })
        .whereType<MapEntry<AdAttributeModel, String>>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdDetailsController>();
    return Obx(() {
      final ad = controller.ad.value;
      if (ad == null) return const SizedBox.shrink();

      final isEn = LocalizeAndTranslate.getLanguageCode() == 'en';
      final currency = ad.currencySymbol ?? '';
      final category =
          isEn
              ? (ad.categoryNameEn?.isNotEmpty == true
                  ? ad.categoryNameEn
                  : ad.categoryName)
              : (ad.categoryName?.isNotEmpty == true
                  ? ad.categoryName
                  : ad.categoryNameEn);

      final attributeRows =
          _filterAttributes(ad.attributes, isEn)
              .map(
                (item) => DetailRow(
                  label: item.key.displayLabel(isEn),
                  value: item.value,
                ),
              )
              .toList();

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailRow(
              label: AppStrings.priceText,
              value: '$currency${ad.price}',
              valueTextColor: AppColors.primary,
            ),
            DetailRow(
              label: AppStrings.listingDateText,
              value: _formatDate(ad.createdAt),
            ),
            DetailRow(
              label: AppStrings.adNumberText,
              value: ad.id.toString(),
              valueTextColor: AppColors.red,
            ),
            if (category != null && category.isNotEmpty)
              DetailRow(label: AppStrings.categoryText, value: category),
            ...attributeRows,
            const SizedBox(height: 12.0),
            const FeaturesSection(),
            const QuestionsSection(),
          ],
        ),
      );
    });
  }
}
