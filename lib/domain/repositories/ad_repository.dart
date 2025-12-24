import '../entities/ad_entity.dart';

abstract class AdRepository {
  Future<List<AdEntity>> fetchFilteredAds(
    String query,
    String appearance, {
    int? categoryId,
    int? subCategoryId,
    int? subSubCategoryId,
  });
}
