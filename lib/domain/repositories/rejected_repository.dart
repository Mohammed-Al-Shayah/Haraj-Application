import 'package:haraj_adan_app/domain/entities/rejected_entity.dart';

abstract class RejectedRepository {
  Future<List<RejectedEntity>> getAds({required int userId});
}
