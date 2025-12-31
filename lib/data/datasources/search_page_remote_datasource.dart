import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/data/models/search_filter_models.dart';

abstract class SearchPageRemoteDataSource {
  Future<List<FilterCategoryModel>> getFilterCategories();
  Future<List<CurrencyModel>> getCurrencies();
}

class SearchPageRemoteDataSourceImpl implements SearchPageRemoteDataSource {
  final ApiClient apiClient;
  List<FilterCategoryModel>? _cachedCategories;
  List<CurrencyModel>? _cachedCurrencies;

  SearchPageRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<FilterCategoryModel>> getFilterCategories() async {
    if (_cachedCategories != null) return _cachedCategories!;

    final res = await apiClient.get(ApiEndpoints.filterCategories);
    final list = _extractList(res);
    _cachedCategories = list
        .whereType<Map<String, dynamic>>()
        .map(FilterCategoryModel.fromJson)
        .toList();
    return _cachedCategories!;
  }

  @override
  Future<List<CurrencyModel>> getCurrencies() async {
    if (_cachedCurrencies != null) return _cachedCurrencies!;

    final res = await apiClient.get(ApiEndpoints.currencies);
    final list = _extractList(res);
    _cachedCurrencies = list
        .whereType<Map<String, dynamic>>()
        .map(CurrencyModel.fromJson)
        .toList();
    return _cachedCurrencies!;
  }

  List<dynamic> _extractList(dynamic res) {
    if (res is Map && res['data'] is List) {
      return List<dynamic>.from(res['data'] as List);
    }
    if (res is List) {
      return List<dynamic>.from(res);
    }
    return <dynamic>[];
  }
}
