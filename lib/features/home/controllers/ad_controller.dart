import 'dart:async';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';
import 'package:haraj_adan_app/data/models/search_filter_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/ad_entity.dart';
import '../../../domain/entities/filtered_ads_result.dart';
import '../../../domain/repositories/ad_repository.dart';

enum SearchState { initial, loading, success, error }

class AdController extends GetxController {
  final AdRepository repository;
  static const String _recentSearchesKey = 'recent_searches';

  AdController({required this.repository});

  var searchQuery = ''.obs;
  var filteredAds = <AdEntity>[].obs;
  var totalResults = 0.obs;
  var totalPages = 1.obs;
  var currentPage = 1.obs;
  var recentSearches = <String>[].obs;
  var searchState = SearchState.initial.obs;
  var selectedAppearance = 'List'.obs;
  var selectedSortOption = ''.obs;
  var isLoadingMore = false.obs;
  var errorMessage = RxnString();
  final int pageLimit = 10;

  double? minPrice;
  double? maxPrice;
  int? currencyId;
  List<AttributeSelection> attributes = [];
  List<CheckboxSelection> checkboxes = [];

  int? categoryId;
  int? subCategoryId;
  int? subSubCategoryId;

  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    _loadRecentSearches();
  }

  void setCategoryFilters({
    int? categoryId,
    int? subCategoryId,
    int? subSubCategoryId,
  }) {
    this.categoryId = categoryId;
    this.subCategoryId = subCategoryId;
    this.subSubCategoryId = subSubCategoryId;
    resetFilters(keepSearch: true, keepCategory: true);
  }

  void resetFilters({bool keepSearch = false, bool keepCategory = false}) {
    if (!keepCategory) {
      categoryId = null;
      subCategoryId = null;
      subSubCategoryId = null;
    }
    minPrice = null;
    maxPrice = null;
    currencyId = null;
    attributes = [];
    checkboxes = [];
    selectedSortOption.value = '';
    currentPage.value = 1;
    totalResults.value = 0;
    totalPages.value = 1;
    errorMessage.value = null;
    if (!keepSearch) {
      searchQuery.value = '';
    }
    filteredAds.clear();
  }

  void updateSortOption(String option) {
    selectedSortOption.value = option;
    currentPage.value = 1;
    _fetchAdsWithDebounce(searchQuery.value);
  }

  void updatePriceAndCurrency({
    double? minPrice,
    double? maxPrice,
    int? currencyId,
  }) {
    this.minPrice = minPrice;
    this.maxPrice = maxPrice;
    this.currencyId = currencyId;
    currentPage.value = 1;
    _fetchAdsWithDebounce(searchQuery.value);
  }

  void applyFilters({
    double? minPrice,
    double? maxPrice,
    int? currencyId,
    List<AttributeSelection>? attributes,
    List<CheckboxSelection>? checkboxes,
  }) {
    this.minPrice = minPrice;
    this.maxPrice = maxPrice;
    this.currencyId = currencyId;
    if (attributes != null) this.attributes = attributes;
    if (checkboxes != null) this.checkboxes = checkboxes;
    currentPage.value = 1;
    _fetchAdsWithDebounce(searchQuery.value);
  }

  void updateAttributes({
    List<AttributeSelection>? attributes,
    List<CheckboxSelection>? checkboxes,
  }) {
    if (attributes != null) this.attributes = attributes;
    if (checkboxes != null) this.checkboxes = checkboxes;
    currentPage.value = 1;
    _fetchAdsWithDebounce(searchQuery.value);
  }

  void filterAds(String query, {bool resetPage = true}) {
    if (resetPage) currentPage.value = 1;
    _fetchAdsWithDebounce(query);
  }

  void addRecentSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    recentSearches.remove(trimmed);
    recentSearches.insert(0, trimmed);

    if (recentSearches.length > 5) {
      recentSearches.removeRange(5, recentSearches.length);
    }

    _persistRecentSearches();
  }

  void clearRecentSearches() {
    recentSearches.clear();
    _persistRecentSearches();
  }

  Future<void> loadNextPage() async {
    if (searchState.value == SearchState.loading || isLoadingMore.value) {
      return;
    }
    if (currentPage.value >= totalPages.value) return;
    currentPage.value += 1;
    await _fetchAds(appendResults: true);
  }

  void _fetchAdsWithDebounce(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      searchQuery.value = query;
      await _fetchAds();
    });
  }

  Future<void> _fetchAds({bool appendResults = false}) async {
    if (appendResults) {
      isLoadingMore.value = true;
    } else {
      searchState.value = SearchState.loading;
      errorMessage.value = null;
    }
    try {
      final FilteredAdsResult result = await repository.fetchFilteredAds(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        appearance: selectedAppearance.value,
        categoryId: categoryId,
        subCategoryId: subCategoryId,
        subSubCategoryId: subSubCategoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        currencyId: currencyId,
        sortBy: _mapSortToCode(selectedSortOption.value),
        page: currentPage.value,
        limit: pageLimit,
        attributes: attributes,
        checkboxes: checkboxes,
      );

      if (appendResults) {
        filteredAds.addAll(result.ads);
      } else {
        filteredAds.value = result.ads;
      }
      totalResults.value = result.total;
      totalPages.value = result.totalPages;
      searchState.value = SearchState.success;

      if (!appendResults) {
        addRecentSearch(searchQuery.value);
      }
    } catch (e) {
      if (appendResults && currentPage.value > 1) {
        currentPage.value -= 1;
      }
      final message = e.toString();
      errorMessage.value =
          message.isNotEmpty ? message : 'Unable to load results';
      if (appendResults) {
        AppSnack.error(AppStrings.errorTitle, 'Unable to load more results');
      } else {
        searchState.value = SearchState.error;
        AppSnack.error(
          AppStrings.errorTitle,
          errorMessage.value ?? 'Unable to load results',
        );
      }
    } finally {
      if (appendResults) {
        isLoadingMore.value = false;
      }
    }
  }

  String? _mapSortToCode(String option) {
    if (option.isEmpty) return null;
    if (option == AppStrings.lowestPrice) return 'price_asc';
    if (option == AppStrings.highestPrice) return 'price_desc';
    if (option == AppStrings.descendingByDate) return 'date_desc';
    if (option == AppStrings.ascendingByDate) return 'date_asc';
    if (option == AppStrings.byAddressAZ) return 'address_asc';
    if (option == AppStrings.byAddressZA) return 'address_desc';
    if (option == AppStrings.nearest) return 'nearest';
    return null; // relevance or unsupported sorts fall back to backend default
  }

  Future<void> _persistRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, recentSearches.toList());
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_recentSearchesKey);
    if (saved != null && saved.isNotEmpty) {
      recentSearches.assignAll(saved.take(5));
    }
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }
}
