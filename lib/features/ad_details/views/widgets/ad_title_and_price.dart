import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import 'package:haraj_adan_app/features/ad_details/controllers/ad_details_controller.dart';

class AdTitleAndPrice extends StatelessWidget {
  const AdTitleAndPrice({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdDetailsController>();
    return Obx(() {
      final ad = controller.ad.value;
      if (ad == null) return const SizedBox.shrink();

      final currency = ad.currencySymbol ?? '';
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                ad.title.isNotEmpty ? ad.title : ad.titleEn,
                style: AppTypography.semiBold20,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$currency${ad.price}',
              style: AppTypography.semiBold18.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      );
    });
  }
}
