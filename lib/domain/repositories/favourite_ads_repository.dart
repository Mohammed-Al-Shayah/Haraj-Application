import '../entities/favourite_ads_entity.dart';

abstract class FavouriteAdsRepository {
  Future<List<FavouriteAdsEntity>> getFavouriteAds();
}
