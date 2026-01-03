import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/core/storage/user_storage.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';
import 'package:haraj_adan_app/domain/repositories/post_ad_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeaturePlanController extends GetxController {
  FeaturePlanController({
    required this.postAdRepository,
    required this.apiClient,
    required this.adId,
    this.onApplied,
  });

  final PostAdRepository postAdRepository;
  final ApiClient apiClient;
  final int adId;
  final VoidCallback? onApplied;

  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;

  final RxDouble featuredPricePerDay = 0.0.obs;
  final RxInt featuredDefaultDays = 0.obs;
  final RxList<dynamic> discounts = <dynamic>[].obs;
  final RxnInt selectedDiscountId = RxnInt();
  final RxDouble selectedDiscountPercentage = 0.0.obs;
  final RxInt selectedDiscountPeriod = 0.obs;

  final RxBool isFeaturedEnabled = true.obs;
  final RxDouble walletBalance = 0.0.obs;

  bool _hasLoaded = false;

  Future<void> loadData({bool force = false}) async {
    if (_hasLoaded && !force) return;
    _hasLoaded = true;
    isLoading(true);
    try {
      await Future.wait([
        _loadFeaturedSettings(),
        _loadDiscounts(),
        _loadWalletBalance(),
      ]);
    } catch (e) {
      if (kDebugMode) debugPrint('feature plan load error: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> _loadFeaturedSettings() async {
    final Map<String, dynamic> data =
        await postAdRepository.getFeaturedSettings();
    featuredPricePerDay.value = _asDouble(data['featured_ad_price']);
    featuredDefaultDays.value = _asInt(data['featured_ad_days_count']);
  }

  Future<void> _loadDiscounts() async {
    discounts.assignAll(await postAdRepository.getDiscounts());
  }

  Future<void> _loadWalletBalance() async {
    final int? userId = await getUserIdFromPrefs();
    if (userId == null) return;

    try {
      final Map<String, dynamic> res = await apiClient.get(
        '${ApiEndpoints.walletSummary}/$userId',
      );
      final dynamic data = res['data'] ?? res;
      final dynamic bal =
          (data is Map<String, dynamic>) ? data['balance'] : null;
      if (bal != null) {
        walletBalance.value = _asDouble(bal);
        return;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('wallet summary fallback: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('_userData');
    if (userJson == null) return;

    final dynamic user = jsonDecode(userJson);
    final dynamic walletList = (user is Map) ? user['user_wallet'] : null;
    if (walletList is List && walletList.isNotEmpty) {
      final dynamic bal = walletList.first['balance'];
      walletBalance.value = _asDouble(bal);
    }
  }

  double calculateFinalPrice() {
    final double perDay = featuredPricePerDay.value;
    final int defaultDays = featuredDefaultDays.value;
    final int extraDays = selectedDiscountPeriod.value;
    final double pct = selectedDiscountPercentage.value;

    final int totalDays = defaultDays + extraDays;
    final double gross = perDay * totalDays;
    final double discount = gross * (pct / 100.0);

    return gross - discount;
  }

  int totalDays() => featuredDefaultDays.value + selectedDiscountPeriod.value;

  bool canPay() {
    if (!isFeaturedEnabled.value) return true;
    return walletBalance.value >= calculateFinalPrice();
  }

  void selectDiscount(dynamic discount) {
    if (discount == null) {
      selectedDiscountId.value = null;
      selectedDiscountPercentage.value = 0.0;
      selectedDiscountPeriod.value = 0;
      return;
    }

    if (discount is! Map) return;

    selectedDiscountId.value = _asInt(discount['id']);
    selectedDiscountPercentage.value = _asDouble(discount['percentage']);
    selectedDiscountPeriod.value = _asInt(discount['period']);
  }

  void setFeaturedEnabled(bool enabled) {
    isFeaturedEnabled.value = enabled;
    if (!enabled) selectDiscount(null);
  }

  Future<void> submit() async {
    if (isSubmitting.value) return;

    final int? userId = await getUserIdFromPrefs();
    if (userId == null) {
      AppSnack.error(AppStrings.errorTitle, AppStrings.userNotFound);
      return;
    }

    if (isFeaturedEnabled.value && !canPay()) {
      AppSnack.error(AppStrings.errorTitle, AppStrings.featureRequestFailed);
      return;
    }

    isSubmitting(true);
    try {
      if (isFeaturedEnabled.value) {
        await postAdRepository.featureAd(
          adId,
          userId: userId,
          discountId: selectedDiscountId.value,
          status: true,
        );
      } else {
        await postAdRepository.refundFeaturedAd(adId);
      }

      AppSnack.success(
        AppStrings.successTitle,
        AppStrings.featureRequestSuccess,
      );
      onApplied?.call();
      Get.back();
    } catch (e) {
      String message = AppStrings.featureRequestFailed;
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['message'] is String) {
          message = data['message'].toString();
        }
      }
      AppSnack.error(AppStrings.errorTitle, message);
    } finally {
      isSubmitting(false);
    }
  }

  double _asDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}
