import '../../domain/entities/shopping_ad_entity.dart';
import '../../domain/repositories/shopping_ad_repository.dart';
import '../datasources/shopping_ad_remote_datasource.dart';

class ShoppingAdRepositoryImpl implements ShoppingAdRepository {
  final ShoppingAdRemoteDataSource remoteDataSource;

  ShoppingAdRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ShoppingAdEntity>> getShoppingAds({
    required double latitude,
    required double longitude,
    double? radiusKm,
  }) async {
    try {
      final models = await remoteDataSource.getShoppingAds(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      return [];
    }
  }
}
