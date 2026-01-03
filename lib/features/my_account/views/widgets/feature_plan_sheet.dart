import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import 'package:haraj_adan_app/domain/repositories/post_ad_repository.dart';
import 'package:haraj_adan_app/features/my_account/controllers/feature_plan_controller.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class FeaturePlanSheet extends StatelessWidget {
  const FeaturePlanSheet({super.key, required this.controller});

  final FeaturePlanController controller;

  static Future<void> show({
    required int adId,
    required PostAdRepository postAdRepository,
    VoidCallback? onApplied,
  }) async {
    final String tag = 'feature_plan_$adId';
    if (Get.isRegistered<FeaturePlanController>(tag: tag)) {
      Get.delete<FeaturePlanController>(tag: tag);
    }
    final ctrl = Get.put(
      FeaturePlanController(
        postAdRepository: postAdRepository,
        apiClient: ApiClient(client: Dio()),
        adId: adId,
        onApplied: onApplied,
      ),
      tag: tag,
    );

    await ctrl.loadData(force: true);

    return Get.bottomSheet(
      FeaturePlanSheet(controller: ctrl),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _t('Featured Ad Plan', 'خطة الإعلان المميز'),
                      style: AppTypography.bold18,
                    ),
                    IconButton(
                      onPressed: Get.back,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _FeaturedPlanContent(controller: controller),
                const SizedBox(height: 16),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed:
                          controller.isSubmitting.value
                              ? null
                              : () {
                                if (!controller.isFeaturedEnabled.value) {
                                  Get.back();
                                  return;
                                }
                                controller.submit();
                              },
                      child:
                          controller.isSubmitting.value
                              ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Text(
                                controller.isFeaturedEnabled.value
                                    ? AppStrings.featureAd
                                    : AppStrings.cancelButtonText,
                                style: AppTypography.bold16.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _FeaturedPlanContent extends StatelessWidget {
  const _FeaturedPlanContent({required this.controller});

  final FeaturePlanController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool enabled = controller.isFeaturedEnabled.value;
      final double pricePerDay = controller.featuredPricePerDay.value;
      final int defaultDays = controller.featuredDefaultDays.value;
      final double wallet = controller.walletBalance.value;
      final int? selectedId = controller.selectedDiscountId.value;
      final int totalDays = controller.totalDays();
      final double finalPrice = controller.calculateFinalPrice();

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
            title: Text(_t('Promote this ad', 'ترقية هذا الإعلان')),
            subtitle: Text(
              _t(
                'Enable featured ad before submitting',
                'تفعيل الإعلان المميز قبل الإرسال',
              ),
            ),
            value: enabled,
            onChanged: controller.setFeaturedEnabled,
          ),
          if (enabled) ...[
            if (controller.discounts.isNotEmpty) ...[
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
                    controller.discounts.map((d) {
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
                        onSelected:
                            (v) => controller.selectDiscount(v ? d : null),
                      );
                    }).toList(),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(_t('No discounts available', 'لا توجد خصومات متاحة')),
            ],
            const SizedBox(height: 8),
            Text('${_t('Total days', 'مجموع الأيام')}: $totalDays'),
            Text(
              '${_t('Final price', 'السعر النهائي')}: ${finalPrice.toStringAsFixed(2)}',
            ),
            if (!controller.canPay())
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
