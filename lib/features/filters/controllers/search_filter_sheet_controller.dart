import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';
import 'package:haraj_adan_app/data/datasources/search_page_remote_datasource.dart';
import 'package:haraj_adan_app/data/models/search_filter_models.dart';
import 'package:haraj_adan_app/features/home/controllers/ad_controller.dart';

class SearchFilterSheetController extends GetxController {
  SearchFilterSheetController({
    required this.categoryId,
    required this.categoryTitle,
    required this.adController,
    SearchPageRemoteDataSource? dataSource,
  }) : remoteDataSource =
           dataSource ??
           (_sharedDataSource ??= SearchPageRemoteDataSourceImpl(_apiClient));

  final int categoryId;
  final String categoryTitle;
  final AdController adController;
  final SearchPageRemoteDataSource remoteDataSource;

  static SearchPageRemoteDataSource? _sharedDataSource;

  static ApiClient get _apiClient {
    if (Get.isRegistered<ApiClient>()) {
      return Get.find<ApiClient>();
    }
    return ApiClient(client: Dio());
  }

  final categories = <FilterCategoryModel>[].obs;
  final currencies = <CurrencyModel>[].obs;
  final Rxn<FilterCategoryModel> selectedCategory = Rxn<FilterCategoryModel>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  final RxMap<int, dynamic> selectedValues = <int, dynamic>{}.obs;
  final RxnInt selectedCurrencyId = RxnInt();
  final Map<int, TextEditingController> _textControllers = {};

  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    isLoading(true);
    errorMessage.value = null;
    try {
      final fetched = await remoteDataSource.getFilterCategories();
      final filteredCategories =
          fetched.where((c) {
            final name = c.name.trim();
            final nameEn = (c.nameEn ?? '').trim().toLowerCase();
            final isRealEstate = name == 'عقارات' || nameEn == 'real estate';
            return !isRealEstate;
          }).toList();

      categories.assignAll(filteredCategories);
      currencies.assignAll(await remoteDataSource.getCurrencies());
      final preferredCategoryId =
          adController.subSubCategoryId ??
          adController.subCategoryId ??
          adController.categoryId ??
          categoryId;
      selectedCategory.value =
          _findCategory(preferredCategoryId) ??
          _findCategoryByTitle(categoryTitle) ??
          (categories.isNotEmpty ? categories.first : null);
      _hydrateFromAdController();
    } catch (e) {
      errorMessage.value = e.toString();
      AppSnack.error('Error', 'Failed to load filters');
    } finally {
      isLoading(false);
    }
  }

  void retry() => _bootstrap();

  void selectCategory(int id) {
    final found = _findCategory(id);
    if (found == null) return;
    selectedCategory.value = found;
    selectedValues.clear();
    selectedCurrencyId.value = null;
    minPriceController.clear();
    maxPriceController.clear();
    _clearAttributeTextControllers(disposeControllers: true);
    adController
      ..categoryId = id
      ..subCategoryId = null
      ..subSubCategoryId = null
      ..minPrice = null
      ..maxPrice = null
      ..currencyId = null
      ..attributes = const []
      ..checkboxes = const [];
  }

  void resetAndApply() {
    selectedValues.clear();
    minPriceController.clear();
    maxPriceController.clear();
    selectedCurrencyId.value = null;
    _clearAttributeTextControllers(disposeControllers: true);
    adController.applyFilters(
      minPrice: null,
      maxPrice: null,
      currencyId: null,
      attributes: const [],
      checkboxes: const [],
    );
  }

  void applyFilters() {
    final double? minPrice = _parsePrice(minPriceController.text);
    final double? maxPrice = _parsePrice(maxPriceController.text);

    final List<AttributeSelection> attributes = <AttributeSelection>[];
    final List<CheckboxSelection> checkboxes = <CheckboxSelection>[];

    selectedValues.forEach((attrId, value) {
      if (value is int) {
        attributes.add(
          AttributeSelection(attributeId: attrId, attributeValueId: value),
        );
      } else if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isNotEmpty) {
          attributes.add(
            AttributeSelection(attributeId: attrId, value: trimmed),
          );
        }
      } else if (value is Set<int> && value.isNotEmpty) {
        checkboxes.add(
          CheckboxSelection(
            attributeId: attrId,
            attributeValueIds: value.toList(),
          ),
        );
      }
    });

    if (selectedCategory.value != null) {
      adController
        ..categoryId = selectedCategory.value!.id
        ..subCategoryId = null
        ..subSubCategoryId = null;
    }

    adController.applyFilters(
      minPrice: minPrice,
      maxPrice: maxPrice,
      currencyId: selectedCurrencyId.value,
      attributes: attributes,
      checkboxes: checkboxes,
    );
  }

  void toggleValue(
    CategoryAttributeModel attr,
    CategoryAttributeValueModel value,
  ) {
    final String type = attr.typeCode.toLowerCase().trim();
    if (type == 'checkbox') {
      final current =
          selectedValues[attr.id] is Set<int>
              ? (selectedValues[attr.id] as Set<int>)
              : <int>{};
      if (current.contains(value.id)) {
        current.remove(value.id);
      } else {
        current.add(value.id);
      }
      selectedValues[attr.id] = {...current};
      return;
    }

    // select / radio / default -> single choice
    selectedValues[attr.id] = value.id;
  }

  void hydrateCurrency(int? id) {
    if (id == null) return;
    final exists = currencies.any((c) => c.id == id);
    if (exists) selectedCurrencyId.value = id;
  }

  FilterCategoryModel? _findCategory(int? id) {
    if (id == null) return null;
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  FilterCategoryModel? _findCategoryByTitle(String title) {
    final normalizedTitle = _normalize(title);
    if (normalizedTitle.isEmpty) return null;
    for (final c in categories) {
      final nName = _normalize(c.name);
      final nNameEn = _normalize(c.nameEn ?? '');
      if (nName == normalizedTitle || nNameEn == normalizedTitle) return c;
    }
    return null;
  }

  String _normalize(String input) =>
      input.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  double? _parsePrice(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }

  void _hydrateFromAdController() {
    if (adController.minPrice != null) {
      minPriceController.text = adController.minPrice!.toString();
    }
    if (adController.maxPrice != null) {
      maxPriceController.text = adController.maxPrice!.toString();
    }
    hydrateCurrency(adController.currencyId);

    for (final attr in adController.attributes) {
      if (attr.value != null && attr.value!.trim().isNotEmpty) {
        selectedValues[attr.attributeId] = attr.value;
        _textControllers[attr.attributeId] = TextEditingController(
          text: attr.value,
        );
      } else if (attr.attributeValueId != null) {
        selectedValues[attr.attributeId] = attr.attributeValueId;
      }
    }
    for (final checkbox in adController.checkboxes) {
      selectedValues[checkbox.attributeId] = checkbox.attributeValueIds.toSet();
    }
  }

  @override
  void onClose() {
    minPriceController.dispose();
    maxPriceController.dispose();
    _clearAttributeTextControllers(disposeControllers: true);
    super.onClose();
  }

  TextEditingController controllerForAttribute(int attributeId) {
    return _textControllers.putIfAbsent(
      attributeId,
      () => TextEditingController(),
    );
  }

  void _clearAttributeTextControllers({bool disposeControllers = false}) {
    if (disposeControllers) {
      for (final controller in _textControllers.values) {
        controller.dispose();
      }
    }
    _textControllers.clear();
  }
}
