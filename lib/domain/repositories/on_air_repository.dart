import '../entities/on_air_entity.dart';

abstract class OnAirRepository {
  Future<List<OnAirEntity>> getAds();
}
