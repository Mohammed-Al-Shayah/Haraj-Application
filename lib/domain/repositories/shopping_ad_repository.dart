import '../entities/shopping_ad_entity.dart';

abstract class ShoppingAdRepository {
  Future<List<ShoppingAdEntity>> getShoppingAds({
    required double latitude,
    required double longitude,
    double? radiusKm,
  });
}
