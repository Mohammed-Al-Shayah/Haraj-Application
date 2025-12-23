import '../../domain/entities/ad_entity.dart';
import '../../domain/repositories/ad_repository.dart';
import '../datasources/ads_remote_datasource.dart';

class AdRepositoryImpl implements AdRepository {
  final AdsRemoteDataSource remoteDataSource;

  AdRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AdEntity>> fetchFilteredAds(
    String query,
    String appearance,
  ) async {
    final ads = await remoteDataSource.getAds(query);

    if (appearance == 'On Map') {
      return ads.where((ad) => ad.latitude != 0 && ad.longitude != 0).toList();
    }

    return ads;
  }
}
