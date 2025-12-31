import 'package:haraj_adan_app/data/models/search_filter_models.dart';
import '../entities/filtered_ads_result.dart';

abstract class AdRepository {
  Future<FilteredAdsResult> fetchFilteredAds({
    String? search,
    String appearance = 'List',
    int? categoryId,
    int? subCategoryId,
    int? subSubCategoryId,
    double? minPrice,
    double? maxPrice,
    int? currencyId,
    String? sortBy,
    int page = 1,
    int limit = 10,
    List<AttributeSelection> attributes = const [],
    List<CheckboxSelection> checkboxes = const [],
  });
}
