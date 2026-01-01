import 'package:haraj_adan_app/data/datasources/rejected_remote_datasource.dart';
import 'package:haraj_adan_app/domain/entities/rejected_entity.dart';
import 'package:haraj_adan_app/domain/repositories/rejected_repository.dart';

class RejectedRepositoryImpl implements RejectedRepository {
  final RejectedRemoteDataSource remoteDataSource;

  RejectedRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<RejectedEntity>> getAds({required int userId}) async {
    return remoteDataSource.fetchAds(userId: userId);
  }
}
