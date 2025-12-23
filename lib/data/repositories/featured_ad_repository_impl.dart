import '../../domain/entities/featured_ad_entity.dart';
import '../../domain/repositories/featured_ad_repository.dart';
import '../datasources/featured_ad_remote_data_source.dart';

class FeaturedAdRepositoryImpl implements FeaturedAdRepository {
  final FeaturedAdRemoteDataSource remoteDataSource;

  FeaturedAdRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<FeaturedAdEntity>> getFeaturedAds() async {
    try {
      final models = await remoteDataSource.getFeaturedAds();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      return [];
    }
  }
}
