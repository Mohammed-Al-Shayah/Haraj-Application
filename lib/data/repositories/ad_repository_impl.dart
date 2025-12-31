import 'package:haraj_adan_app/data/models/search_filter_models.dart';
import '../../domain/entities/filtered_ads_result.dart';
import '../../domain/repositories/ad_repository.dart';
import '../datasources/ads_remote_datasource.dart';

class AdRepositoryImpl implements AdRepository {
  final AdsRemoteDataSource remoteDataSource;

  AdRepositoryImpl({required this.remoteDataSource});

  @override
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
  }) async {
    final result = await remoteDataSource.getAds(
      search: search,
      categoryId: categoryId,
      subCategoryId: subCategoryId,
      subSubCategoryId: subSubCategoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      currencyId: currencyId,
      sortBy: sortBy,
      page: page,
      limit: limit,
      attributes: attributes,
      checkboxes: checkboxes,
    );

    final ads = appearance == 'On Map'
        ? result.ads
            .where((ad) => ad.latitude != 0 && ad.longitude != 0)
            .toList()
        : result.ads;

    return FilteredAdsResult(
      ads: ads,
      total: result.meta.total,
      page: result.meta.page,
      limit: result.meta.limit,
      totalPages: result.meta.totalPages,
    );
  }
}
