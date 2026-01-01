import '../../domain/entities/on_air_entity.dart';
import '../../domain/repositories/on_air_repository.dart';
import '../datasources/on_air_remote_datasource.dart';

class OnAirRepositoryImpl implements OnAirRepository {
  final OnAirRemoteDataSource remoteDataSource;

  OnAirRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<OnAirEntity>> getAds({required int userId}) async {
    return await remoteDataSource.fetchAds(userId: userId);
  }
}
