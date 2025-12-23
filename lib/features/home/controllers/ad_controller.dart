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

  void filterAds(String query) async {
    searchQuery.value = query;
    searchState.value = SearchState.loading;
    try {
      List<AdEntity> ads = await repository.fetchFilteredAds(
        query.isEmpty ? '' : query,
        selectedAppearance.value,
      );
      filteredAds.value = ads;
      searchState.value = SearchState.success;
    } catch (_) {
      searchState.value = SearchState.error;
    }
  }
}
