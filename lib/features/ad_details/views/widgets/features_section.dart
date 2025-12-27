import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import 'package:haraj_adan_app/features/ad_details/views/widgets/feature_row.dart';
import 'package:haraj_adan_app/features/ad_details/models/ad_details_model.dart';
import 'package:get/get.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import '../../controllers/ad_details_controller.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdDetailsController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.featuresText,
          style: AppTypography.semiBold16,
        ),
        const SizedBox(height: 7.0),
        Obx(() {
          final ad = controller.ad.value;
          if (ad == null || ad.attributes.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                AppStrings.unspecifiedText,
                style: AppTypography.normal14,
              ),
            );
          }

          final isEn = LocalizeAndTranslate.getLanguageCode() == 'en';
          final items = ad.attributes
              .map((attr) {
                final value = attr.displayValue(isEn);
                if (value.isEmpty || value == '-') return null;
                return MapEntry(attr, value);
              })
              .whereType<MapEntry<AdAttributeModel, String>>()
              .toList();
          if (items.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                AppStrings.unspecifiedText,
                style: AppTypography.normal14,
              ),
            );
          }

          return Column(
            children: items
                .map(
                  (item) => FeatureRow(
                    label: item.key.displayLabel(isEn),
                    value: item.value,
                  ),
                )
                .toList(),
          );
        }),
      ],
    );
  }
}
