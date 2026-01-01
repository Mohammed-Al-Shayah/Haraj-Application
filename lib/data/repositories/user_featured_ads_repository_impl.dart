import 'package:haraj_adan_app/data/datasources/user_featured_ads_remote_datasource.dart';
import 'package:haraj_adan_app/domain/entities/user_featured_ad_entity.dart';
import 'package:haraj_adan_app/domain/repositories/user_featured_ads_repository.dart';

class UserFeaturedAdsRepositoryImpl implements UserFeaturedAdsRepository {
  final UserFeaturedAdsRemoteDataSource remoteDataSource;

  UserFeaturedAdsRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<UserFeaturedAdEntity>> getAds({required int userId}) async {
    return remoteDataSource.fetchAds(userId: userId);
  }
}
