import '../entities/not_published_entity.dart';

abstract class NotPublishedRepository {
  Future<List<NotPublishedEntity>> getAds({required int userId});
}
