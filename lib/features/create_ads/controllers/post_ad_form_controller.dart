import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/domain/repositories/post_ad_repository.dart';
import 'package:haraj_adan_app/features/create_ads/controllers/create_ads_controller.dart';
import 'package:haraj_adan_app/features/filters/models/enums.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostAdFormController extends GetxController {
  PostAdFormController({required this.repo, required this.categoryId});

  // Dependencies
  final PostAdRepository repo;
  final int categoryId;

  // Form fields
  final RxString title = ''.obs;
  final RxString titleEn = ''.obs;
  final RxString price = ''.obs;
  final RxString descr = ''.obs;
  final RxInt currencyId = 1.obs;

  final RxString lat = ''.obs;
  final RxString lng = ''.obs;
  final RxString address = ''.obs;

  final RxList<File> images = <File>[].obs;

  // Attributes
  // final RxList<Map<String, dynamic>> attributesSchema =
  //     <Map<String, dynamic>>[].obs;
  final RxList<dynamic> attributesSchema = <dynamic>[].obs;

  // Selected values keyed by attribute_id:

  final RxMap<int, dynamic> selectedAttributes = <int, dynamic>{}.obs;

  // Featured / Discounts
  final RxDouble featuredPricePerDay = 0.0.obs;
  final RxInt featuredDefaultDays = 0.obs;

  final RxList<dynamic> discounts = <dynamic>[].obs;
  final RxnInt selectedDiscountId = RxnInt();
  final RxDouble selectedDiscountPercentage = 0.0.obs;
  final RxInt selectedDiscountPeriod = 0.obs;

  final RxBool isFeaturedEnabled = false.obs;

  // Wallet / Loading
  final RxDouble walletBalance = 0.0.obs;

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxnString loadError = RxnString();

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    if (categoryId <= 0) {
      _showError(
        _t('Error', 'حدث خطأ'),
        _t(
          'Category is required before posting an ad',
          'يجب اختيار القسم قبل نشر الإعلان',
        ),
      );
      return;
    }

    isLoading(true);
    try {
      await _loadWalletBalance();
      await _loadAttributes();
      await _loadFeaturedSettings();
      await _loadDiscounts();
      loadError.value = null;
    } catch (e) {
      loadError.value = e.toString();
      _showError(
        _t('Error', 'حدث خطأ'),
        _t('Failed to load ad form data', 'تعذر تحميل بيانات نموذج الإعلان'),
      );
    } finally {
      isLoading(false);
    }
  }

  // Parsing helpers
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

  // Loaders
  Future<void> _loadWalletBalance() async {
    // Debug-only override to test wallet display without real balance.
    // if (kDebugMode) {
    //   const double debugBalanceOverride = 12553.45;
    //   walletBalance.value = debugBalanceOverride;
    //   return;
    // }

    final int? userId = await _getUserId();
    if (userId == null) return;

    try {
      final ApiClient apiClient =
          Get.isRegistered<ApiClient>()
              ? Get.find<ApiClient>()
              : ApiClient(client: Dio());
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
        debugPrint('Failed to fetch wallet summary, fallback to prefs: $e');
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

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('_userData');
    if (userJson == null) return null;

    final dynamic user = jsonDecode(userJson);
    final dynamic id = (user is Map) ? (user['id'] ?? user['user_id']) : null;

    if (id is num) return id.toInt();
    if (id is String) return int.tryParse(id);
    return null;
  }

  Future<void> _loadAttributes() async {
    if (kDebugMode) debugPrint('Loading attributes for categoryId=$categoryId');

    // NOTE: Remote layer returns response['data'] directly (category object).
    final Map<String, dynamic> category = await repo.getCategoryAttributes(
      categoryId,
    );

    final List<dynamic> list =
        (category['category_attributes'] as List?) ?? <dynamic>[];
    attributesSchema.assignAll(list);
    // attributesSchema.assignAll(list.whereType<Map<String, dynamic>>().toList());
  }

  Future<void> _loadFeaturedSettings() async {
    // NOTE: Remote layer returns response['data'] directly.
    final Map<String, dynamic> data = await repo.getFeaturedSettings();

    // featured_ad_price can be string: "100"
    featuredPricePerDay.value = _asDouble(data['featured_ad_price']);
    featuredDefaultDays.value = _asInt(data['featured_ad_days_count']);
  }

  Future<void> _loadDiscounts() async {
    discounts.assignAll(await repo.getDiscounts());
  }

  // Location
  Future<Position?> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return null;
    }
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> ensureLocationIfEmpty() async {
    if (lat.isNotEmpty && lng.isNotEmpty) return;
    final pos = await _getCurrentPosition();
    if (pos != null) {
      lat.value = pos.latitude.toString();
      lng.value = pos.longitude.toString();
    }
  }

  // Normalization / Finders (for auto-mapping specs -> attributes)
  String _normalize(String v) {
    return v
        .toLowerCase()
        .replaceAll(RegExp(r'[_]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Map<String, dynamic>? _findAttr(List<String> candidates) {
    if (attributesSchema.isEmpty) return null;

    final List<String> cands = candidates.map(_normalize).toList();

    for (final raw in attributesSchema) {
      final String name = _normalize((raw['name'] ?? '').toString());
      final String nameEn = _normalize((raw['name_en'] ?? '').toString());

      if (cands.contains(name) || cands.contains(nameEn)) {
        return Map<String, dynamic>.from(raw);
      }
    }
    return null;
  }

  int? _findValueId(Map<String, dynamic> attr, List<String> candidates) {
    final List<dynamic> values =
        (attr['category_attributes_values'] as List?) ?? <dynamic>[];

    if (values.isEmpty) return null;

    final List<String> cands = candidates.map(_normalize).toList();

    for (final v in values) {
      if (v is! Map) continue;

      final String name = _normalize((v['name'] ?? '').toString());
      final String nameEn = _normalize((v['name_en'] ?? '').toString());

      if (cands.contains(name) || cands.contains(nameEn)) {
        return _asInt(v['id']);
      }
    }
    return null;
  }

  bool _isCheckbox(Map<String, dynamic> attr) {
    final dynamic typeObj = attr['category_attributes_types'];
    final String code =
        (typeObj is Map ? (typeObj['code'] ?? '') : '').toString().trim();
    return code.toLowerCase() == 'checkbox';
  }

  // Setters (write into selectedAttributes)
  void _setText(Map<String, dynamic>? attr, dynamic value) {
    if (attr == null || value == null) return;

    final int id = _asInt(attr['id']);
    if (id <= 0) return;

    final dynamic existing = selectedAttributes[id];
    if (existing != null && existing.toString().trim().isNotEmpty) return;

    final String s = value.toString().trim();
    if (s.isEmpty) return;

    selectedAttributes[id] = s;
  }

  void _setSelect(Map<String, dynamic>? attr, List<String> valueCandidates) {
    if (attr == null) return;

    final int id = _asInt(attr['id']);
    if (id <= 0) return;

    if (selectedAttributes[id] != null) return;

    final int? valId = _findValueId(attr, valueCandidates);
    if (valId == null || valId <= 0) return;

    selectedAttributes[id] = valId;
  }

  void _setCheckbox(
    Map<String, dynamic>? attr,
    List<List<String>> valuesCandidates,
  ) {
    if (attr == null) return;

    final int id = _asInt(attr['id']);
    if (id <= 0) return;

    final dynamic existing = selectedAttributes[id];
    if (existing is List && existing.isNotEmpty) return;

    final List<int> out = <int>[];

    for (final c in valuesCandidates) {
      final int? valId = _findValueId(attr, c);
      if (valId != null && valId > 0 && !out.contains(valId)) out.add(valId);
    }

    if (out.isNotEmpty) {
      selectedAttributes[id] = out;
    }
  }

  void _setSelectOrCheckbox(
    Map<String, dynamic>? attr,
    List<List<String>> valuesCandidates,
  ) {
    if (attr == null) return;

    if (_isCheckbox(attr)) {
      _setCheckbox(attr, valuesCandidates);
      return;
    }

    // If it's radio/select, pick first candidate group only.
    if (valuesCandidates.isNotEmpty) {
      _setSelect(attr, valuesCandidates.first);
    }
  }

  // Mappers (business mapping -> candidates)
  List<String> _currencyCandidatesById(int id) {
    if (id == CurrencyOption.rialYemeni.index) {
      return <String>['yemeni rial', 'rial'];
    }
    if (id == CurrencyOption.dollarUsd.index) {
      return <String>['usd', 'dollar', 'us dollar'];
    }
    if (id == CurrencyOption.poundEgp.index) {
      return <String>['egp', 'pound', 'egyptian pound'];
    }
    if (id == CurrencyOption.euro.index) {
      return <String>['euro'];
    }
    return <String>[];
  }

  List<String> _nearbyCandidates(NearbyPlace v) {
    switch (v) {
      case NearbyPlace.airport:
        return <String>['airport', 'مطار'];
      case NearbyPlace.beach:
        return <String>['seaside', 'beach', 'شاطئ البحر'];
      case NearbyPlace.downtown:
        return <String>['city center', 'مركز المدينة'];
      case NearbyPlace.hospital:
        return <String>['hospital', 'مستشفى'];
      case NearbyPlace.amusement:
        return <String>['night clubs', 'ملاهي'];
      case NearbyPlace.school:
        return <String>['school', 'مدرسة'];
      case NearbyPlace.supermarket:
        return <String>['supermarket', 'سوبر ماركت'];
      case NearbyPlace.mosque:
        return <String>['mosque', 'مسجد'];
      case NearbyPlace.mall:
        return <String>['mall', 'مول'];
      case NearbyPlace.clothingCenter:
        return <String>['clothing center', 'مركز ملابس'];
      case NearbyPlace.restaurant:
        return <String>['restaurant', 'مطعم'];
      case NearbyPlace.cafe:
        return <String>['cafe', 'مقهى', 'كوفي'];
      case NearbyPlace.fireStation:
        return <String>['fire station', 'إطفاء'];
      case NearbyPlace.policeStation:
        return <String>['police', 'شرطة', 'مركز شرطة'];
      case NearbyPlace.bank:
        return <String>['bank', 'بنك'];
      case NearbyPlace.popularMarket:
        return <String>['popular market', 'سوق شعبي'];
      case NearbyPlace.university:
        return <String>['university', 'جامعة'];
      case NearbyPlace.gym:
        return <String>['gym', 'نادي رياضي'];
    }
  }

  // Sync Specs -> Attributes
  void syncRealEstateSpecsToAttributes(dynamic specs) {
    if (attributesSchema.isEmpty || specs == null) return;

    // Basic numeric/text
    _setText(
      _findAttr(<String>[
        'rooms',
        'room',
        'عدد الغرف',
        'غرف',
        'number of rooms',
      ]),
      specs.realEstateRooms,
    );

    _setText(
      _findAttr(<String>[
        'bathroom',
        'bathrooms',
        'عدد الحمامات',
        'number of bathrooms',
      ]),
      specs.realEstateBaths,
    );

    _setText(
      _findAttr(<String>['floor', 'floors', 'عدد الطوابق', 'floors count']),
      specs.realEstateFloors,
    );

    final String spaceText = specs.realEstateSpace?.text ?? '';
    _setText(
      _findAttr(<String>['space', 'area', 'مساحة', 'المساحة']),
      spaceText.isNotEmpty ? spaceText : null,
    );

    // Furnishing
    final furnAttr = _findAttr(<String>[
      'furnishing',
      'التأثيث',
      'furnishing type',
    ]);
    if (specs.realEstateFurnitureType is List &&
        specs.realEstateFurnitureType.isNotEmpty) {
      final furn = specs.realEstateFurnitureType.first;
      if (furn == RealEstateFurnitureType.yes) {
        _setSelect(furnAttr, <String>['furnished', 'مؤثث']);
      } else if (furn == RealEstateFurnitureType.no) {
        _setSelect(furnAttr, <String>['unfurnished', 'غير مؤثث']);
      } else if (furn == RealEstateFurnitureType.semi_furnished) {
        _setSelect(furnAttr, <String>['semi furnished', 'شبه مؤثث']);
      }
    }

    // Finishing
    final finishAttr = _findAttr(<String>[
      'finishing',
      'التشطيب',
      'finishing type',
    ]);
    if (specs.realEstateFinishing is List &&
        specs.realEstateFinishing.isNotEmpty) {
      final fin = specs.realEstateFinishing.first;
      if (fin == RealEstateFinishing.full_finishing) {
        _setSelect(finishAttr, <String>['finished', 'مشطبة', 'مشطب']);
      } else if (fin == RealEstateFinishing.part_finishing) {
        _setSelect(finishAttr, <String>[
          'semi finished',
          'شبه مشطبة',
          'شبه مشطب',
        ]);
      } else if (fin == RealEstateFinishing.without_finishing) {
        _setSelect(finishAttr, <String>['unfinished', 'غير مشطب', 'غير مشطبة']);
      }
    }

    // Currency (checkbox OR select based on schema type)
    final currencyAttr = _findAttr(<String>['currency', 'العملة']);
    final List<String> curCands = _currencyCandidatesById(currencyId.value);
    if (currencyAttr != null && curCands.isNotEmpty) {
      _setSelectOrCheckbox(currencyAttr, <List<String>>[curCands]);
    }

    // Ad Type (sale/rent/exchange)
    final adTypeAttr = _findAttr(<String>[
      'ad type',
      'نوع الاعلان',
      'نوع الإعلان',
    ]);
    if (adTypeAttr != null &&
        specs.adCategory is List &&
        specs.adCategory.isNotEmpty) {
      final cat = specs.adCategory.first;
      if (cat == AdCategory.sell) {
        _setSelect(adTypeAttr, <String>['sale', 'بيع']);
      } else if (cat == AdCategory.rent) {
        _setSelect(adTypeAttr, <String>['rent', 'إيجار', 'ايجار']);
      } else if (cat == AdCategory.Switch) {
        _setSelect(adTypeAttr, <String>[
          'exchange',
          'بدل',
          'استبدال',
          'إستبدال',
        ]);
      }
    }

    // Building Age
    final ageAttr = _findAttr(<String>[
      'building age',
      'عمر المبنى',
      'عمر البناء',
    ]);
    if (specs.buildingAge != null) {
      switch (specs.buildingAge) {
        case BuildingAge.lessThan5:
          _setSelect(ageAttr, <String>['under 5 years', 'أقل من 5 سنوات']);
          break;
        case BuildingAge.between5And15:
          _setSelect(ageAttr, <String>['between 5 and 15', 'بين 5 و 15 سنة']);
          break;
        case BuildingAge.moreThan15:
          _setSelect(ageAttr, <String>['more than 15', 'أكثر من 15 سنة']);
          break;
      }
    }

    // Nearby: from CreateAdsController (take first)
    if (Get.isRegistered<CreateAdsController>()) {
      final ctrl = Get.find<CreateAdsController>();
      if (ctrl.nearbyPlaces.isNotEmpty) {
        final nearAttr = _findAttr(<String>['قريبة من', 'close to', 'near']);
        final List<String> cands = _nearbyCandidates(ctrl.nearbyPlaces.first);
        if (nearAttr != null && cands.isNotEmpty) {
          _setSelect(nearAttr, cands);
        }
      }
    }
  }

  // Featured math
  double calculateFeaturedFinalPrice() {
    final double perDay = featuredPricePerDay.value;
    final int defaultDays = featuredDefaultDays.value;

    final int extraDays = selectedDiscountPeriod.value;
    final double pct = selectedDiscountPercentage.value;

    final int totalDays = defaultDays + extraDays;
    final double gross = perDay * totalDays;
    final double discount = gross * (pct / 100.0);

    return gross - discount;
  }

  bool canPayFeatured() {
    if (!isFeaturedEnabled.value) return true;
    return walletBalance.value >= calculateFeaturedFinalPrice();
  }

  void setFeaturedEnabled(bool enabled) {
    isFeaturedEnabled.value = enabled;
    if (!enabled) {
      selectDiscount(null);
    }
  }

  // Validation + Payload
  bool validateRequiredAttributes() {
    for (final raw in attributesSchema) {
      if (raw['is_required'] != true) continue;

      final int id = _asInt(raw['id']);
      if (id <= 0) continue;

      final dynamic v = selectedAttributes[id];

      // Required can be:
      // - int (valueId)
      // - List<int> (checkbox)
      // - String (text/number)
      final bool ok =
          v != null &&
          ((v is List) ? v.isNotEmpty : v.toString().trim().isNotEmpty);

      if (!ok) return false;
    }
    return true;
  }

  List<Map<String, dynamic>> buildAttributesPayload() {
    final List<Map<String, dynamic>> out = <Map<String, dynamic>>[];

    for (final entry in selectedAttributes.entries) {
      final int attrId = entry.key;
      final dynamic value = entry.value;

      if (attrId <= 0) continue;

      final String type = _attrTypeCode(attrId);

      if (type == 'checkbox') {
        final List<int> values =
            value is List ? value.whereType<int>().toList() : <int>[];
        for (final int v in values) {
          if (v <= 0) continue;
          out.add(<String, dynamic>{
            'category_attribute_id': attrId,
            'category_attribute_value_id': v,
          });
        }
        continue;
      }

      if (type == 'select' || type == 'radio') {
        final List<int> values = <int>[];
        if (value is int) values.add(value);
        if (value is List) values.addAll(value.whereType<int>());
        if (values.isNotEmpty && values.first > 0) {
          out.add(<String, dynamic>{
            'category_attribute_id': attrId,
            'category_attribute_value_id': values.first,
          });
        }
        continue;
      }

      // text / number or unknown -> send as text
      final String txt = value.toString().trim();
      if (txt.isNotEmpty) {
        out.add(<String, dynamic>{
          'category_attribute_id': attrId,
          'text': txt,
        });
      }
    }

    return out;
  }

  String _attrTypeCode(int id) {
    for (final raw in attributesSchema) {
      final int attrId = _asInt(raw['id']);
      if (attrId != id) continue;
      final dynamic typeObj = raw['category_attributes_types'];
      return (typeObj is Map ? (typeObj['code'] ?? '') : '')
          .toString()
          .toLowerCase();
    }
    return '';
  }

  Map<String, dynamic>? buildFeaturedPayload() {
    if (!isFeaturedEnabled.value) return null;

    return <String, dynamic>{
      'status': true,
      if (selectedDiscountId.value != null)
        'discount_id': selectedDiscountId.value,
    };
  }

  // Submit
  Future<void> submit() async {
    if (isSubmitting.value) return;

    if (Get.isRegistered<CreateAdsController>()) {
      final createAdsCtrl = Get.find<CreateAdsController>();
      if (createAdsCtrl.adType.value == AdType.real_estates) {
        syncRealEstateSpecsToAttributes(createAdsCtrl.adRealEstateSpecs.value);
      }
    }

    if (title.value.trim().isEmpty) {
      _showError(_t('Error', 'خطأ'), _t('Title is required', 'العنوان مطلوب'));
      return;
    }

    if (price.value.trim().isEmpty || double.tryParse(price.value) == null) {
      _showError(_t('Error', 'خطأ'), _t('Price is invalid', 'السعر غير صالح'));
      return;
    }

    if (images.isEmpty) {
      _showError(
        _t('Error', 'خطأ'),
        _t('At least one image is required', 'مطلوب صورة واحدة على الأقل'),
      );
      return;
    }

    if (!validateRequiredAttributes()) {
      _showError(
        _t('Error', 'خطأ'),
        _t('Please fill required attributes', 'يرجى تعبئة الحقول المطلوبة'),
      );
      return;
    }

    if (isFeaturedEnabled.value && !canPayFeatured()) {
      _showError(
        _t('Error', 'خطأ'),
        _t('Insufficient Funds', 'الرصيد غير كافٍ'),
      );
      return;
    }

    final int? userId = await _getUserId();
    if (userId == null) {
      _showError(
        _t('Error', 'خطأ'),
        _t(
          'User not found, login again',
          'المستخدم غير موجود، يرجى إعادة تسجيل الدخول',
        ),
      );
      return;
    }

    isSubmitting(true);
    try {
      final attrs = buildAttributesPayload();
      if (kDebugMode) {
        debugPrint('PostAd submit attrs: ${jsonEncode(attrs)}');
      }

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
        featured: buildFeaturedPayload(),
      );

      _showSuccess(
        _t('Success', 'تم بنجاح'),
        _t('Ad created successfully', 'تم إنشاء الإعلان بنجاح'),
      );
      Get.offAllNamed(Routes.successPostedScreen);
    } catch (e) {
      String message = _t('Failed to submit ad', 'فشل إرسال الإعلان');
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['message'] is String) {
          message = data['message'].toString();
        }
        if (kDebugMode) {
          debugPrint('submit error response: ${e.response?.data}');
        }
      }
      _showError(_t('Error', 'خطأ'), message);
      if (kDebugMode) debugPrint('submit error: $e');
    } finally {
      isSubmitting(false);
    }
  }

  // Discount selection
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

  void _showError(String title, String message) =>
      AppSnack.error(title, message);

  void _showSuccess(String title, String message) =>
      AppSnack.success(title, message);

  String _t(String en, String ar) {
    final lang = LocalizeAndTranslate.getLanguageCode();
    return lang.startsWith('ar') ? ar : en;
  }
}
