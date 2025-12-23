import '../entities/featured_ad_entity.dart';

abstract class FeaturedAdRepository {
  Future<List<FeaturedAdEntity>> getFeaturedAds();
}
