import 'package:get/get.dart';
import '../../../domain/entities/ad_entity.dart';
import '../../../domain/repositories/ad_repository.dart';

enum SearchState { initial, loading, success, error }

class AdController extends GetxController {
  final AdRepository repository;

  AdController({required this.repository});

  var searchQuery = ''.obs;
  var filteredAds = <AdEntity>[].obs;
  var searchState = SearchState.initial.obs;
  var selectedAppearance = 'List'.obs;
  int? categoryId;
  int? subCategoryId;
  int? subSubCategoryId;

  void setCategoryFilters({
    int? categoryId,
    int? subCategoryId,
    int? subSubCategoryId,
  }) {
    this.categoryId = categoryId;
    this.subCategoryId = subCategoryId;
    this.subSubCategoryId = subSubCategoryId;
  }

  void filterAds(String query) async {
    searchQuery.value = query;
    searchState.value = SearchState.loading;
    try {
      List<AdEntity> ads = await repository.fetchFilteredAds(
        query.isEmpty ? '' : query,
        selectedAppearance.value,
        categoryId: categoryId,
        subCategoryId: subCategoryId,
        subSubCategoryId: subSubCategoryId,
      );
      filteredAds.value = ads;
      searchState.value = SearchState.success;
    } catch (_) {
      searchState.value = SearchState.error;
    }
  }
}
