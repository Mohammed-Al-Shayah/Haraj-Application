import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:haraj_adan_app/domain/repositories/post_ad_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostAdFormController extends GetxController {
  final PostAdRepository repo;
  final int categoryId;

  PostAdFormController({required this.repo, required this.categoryId});

  // Form fields
  final title = ''.obs;
  final titleEn = ''.obs;
  final price = ''.obs;
  final descr = ''.obs;
  final currencyId = 1.obs;

  final lat = ''.obs;
  final lng = ''.obs;
  final address = ''.obs;

  final images = <File>[].obs;

  // Dynamic attributes from API
  final attributesSchema = <dynamic>[].obs; // raw
  final selectedAttributes =
      <int, dynamic>{}.obs; // category_attribute_id -> value

  // Featured
  final featuredPricePerDay = 0.0.obs;
  final featuredDefaultDays = 0.obs;
  final discounts = <dynamic>[].obs;
  final selectedDiscountId = RxnInt();
  final selectedDiscountPercentage = 0.0.obs;
  final selectedDiscountPeriod = 0.obs;
  final isFeaturedEnabled = false.obs;

  // Wallet balance (read from prefs/user data)
  final walletBalance = 0.0.obs;

  // Loading
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    isLoading(true);
    try {
      await _loadWalletBalance();
      await _loadAttributes();
      await _loadFeaturedSettings();
      await _loadDiscounts();
    } finally {
      isLoading(false);
    }
  }

  Future<void> _loadWalletBalance() async {
    // حسب مشروعك: انت مخزن _userData في prefs
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('_userData');
    if (userJson == null) return;

    final user = jsonDecode(userJson);

    // حاول تدور على balance من user_wallet
    final walletList = user['user_wallet'];
    if (walletList is List && walletList.isNotEmpty) {
      final bal = walletList.first['balance'];
      walletBalance.value = double.tryParse(bal.toString()) ?? 0.0;
    }
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('_userData');
    if (userJson == null) return null;
    final user = jsonDecode(userJson);
    final id = user['id'] ?? user['user_id'];
    if (id is num) return id.toInt();
    if (id is String) return int.tryParse(id);
    return null;
  }

  Future<void> _loadAttributes() async {
    final res = await repo.getCategoryAttributes(categoryId);
    final list = (res['category_attributes'] as List?) ?? [];
    attributesSchema.assignAll(list);
  }

  Future<void> _loadFeaturedSettings() async {
    final res = await repo.getFeaturedSettings();
    featuredPricePerDay.value =
        (res['featured_ad_price'] as num?)?.toDouble() ?? 0.0;
    featuredDefaultDays.value =
        (res['featured_ad_days_count'] as num?)?.toInt() ?? 0;
  }

  Future<void> _loadDiscounts() async {
    discounts.assignAll(await repo.getDiscounts());
  }

  // Featured price formula (حسب العميل)
  double calculateFeaturedFinalPrice() {
    final perDay = featuredPricePerDay.value;
    final defaultDays = featuredDefaultDays.value;

    final discountPeriod = selectedDiscountPeriod.value;
    final discountPct = selectedDiscountPercentage.value;

    final totalDays = defaultDays + discountPeriod;
    final gross = perDay * totalDays;
    final discountAmount = gross * (discountPct / 100.0);
    final finalPrice = gross - discountAmount;

    return finalPrice;
  }

  bool canPayFeatured() {
    if (!isFeaturedEnabled.value) return true;
    final finalPrice = calculateFeaturedFinalPrice();
    return walletBalance.value >= finalPrice;
  }

  // Validation rules
  bool validateRequiredAttributes() {
    for (final attr in attributesSchema) {
      if (attr is! Map) continue;
      final isRequired = attr['is_required'] == true;
      if (!isRequired) continue;

      final id = (attr['id'] as num?)?.toInt() ?? 0;
      final value = selectedAttributes[id];

      final ok = value != null && value.toString().trim().isNotEmpty;
      if (!ok) return false;
    }
    return true;
  }

  // Build attributes payload (حسب العميل)
  List<Map<String, dynamic>> buildAttributesPayload() {
    final List<Map<String, dynamic>> out = [];

    for (final entry in selectedAttributes.entries) {
      final attrId = entry.key;
      final value = entry.value;

      // value ممكن يكون:
      // - String/num للنص/رقم => text
      // - int للقيم (select/radio/checkbox) => category_attribute_value_id
      // - List<int> للـ checkbox multiple => عدة entries
      if (value is List<int>) {
        for (final v in value) {
          out.add({
            "category_attribute_id": attrId,
            "category_attribute_value_id": v,
          });
        }
      } else if (value is int) {
        out.add({
          "category_attribute_id": attrId,
          "category_attribute_value_id": value,
        });
      } else {
        out.add({"category_attribute_id": attrId, "text": value.toString()});
      }
    }

    return out;
  }

  Map<String, dynamic>? buildFeaturedPayload() {
    if (!isFeaturedEnabled.value) return null;

    return {
      "status": true,
      if (selectedDiscountId.value != null)
        "discount_id": selectedDiscountId.value,
    };
  }

  Future<void> submit() async {
    // basic validation
    if (title.value.trim().isEmpty) {
      Get.snackbar("Error", "Title is required");
      return;
    }
    if (price.value.trim().isEmpty || double.tryParse(price.value) == null) {
      Get.snackbar("Error", "Price is invalid");
      return;
    }
    if (images.isEmpty) {
      Get.snackbar("Error", "At least one image is required");
      return;
    }
    if (!validateRequiredAttributes()) {
      Get.snackbar("Error", "Please fill required attributes");
      return;
    }

    // featured wallet validation (حسب العميل)
    if (isFeaturedEnabled.value && !canPayFeatured()) {
      Get.snackbar("Error", "Insufficient Funds");
      return;
    }

    final userId = await _getUserId();
    if (userId == null) {
      Get.snackbar("Error", "User not found, login again");
      return;
    }

    isSubmitting(true);
    try {
      final attrs = buildAttributesPayload();
      final featured = buildFeaturedPayload();

      await repo.createAd(
        userId: userId,
        categoryId: categoryId,
        title: title.value.trim(),
        titleEn: titleEn.value.trim().isEmpty ? null : titleEn.value.trim(),
        price: double.parse(price.value),
        currencyId: currencyId.value,
        descr: descr.value.trim().isEmpty ? null : descr.value.trim(),
        lat: lat.value,
        lng: lng.value,
        address: address.value,
        images: images.toList(),
        attributes: attrs,
        featured: featured,
      );

      Get.snackbar("Success", "Ad created successfully");
      Get.back(); // أو Go to success screen
    } catch (e) {
      Get.snackbar("Error", "Failed to submit ad");
    } finally {
      isSubmitting(false);
    }
  }

  // discount selection helper
  void selectDiscount(dynamic discount) {
    if (discount is! Map) return;

    selectedDiscountId.value = (discount['id'] as num?)?.toInt();
    selectedDiscountPercentage.value =
        (discount['percentage'] as num?)?.toDouble() ?? 0.0;
    selectedDiscountPeriod.value = (discount['period'] as num?)?.toInt() ?? 0;
  }
}
