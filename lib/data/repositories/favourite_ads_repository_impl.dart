import '../../domain/entities/favourite_ads_entity.dart';
import '../../domain/repositories/favourite_ads_repository.dart';
import '../datasources/favourite_ads_remote_datasource.dart';

class FavouriteAdsRepositoryImpl implements FavouriteAdsRepository {
  final FavouriteAdsRemoteDataSource remoteDataSource;

  FavouriteAdsRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<FavouriteAdsEntity>> getFavouriteAds() async {
    return await remoteDataSource.fetchFavouriteAds();
  }
}
