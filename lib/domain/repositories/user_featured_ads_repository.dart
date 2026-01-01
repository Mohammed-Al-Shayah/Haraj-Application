import 'package:haraj_adan_app/domain/entities/user_featured_ad_entity.dart';

abstract class UserFeaturedAdsRepository {
  Future<List<UserFeaturedAdEntity>> getAds({required int userId});
}
