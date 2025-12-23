import '../../domain/entities/not_published_entity.dart';
import '../../domain/repositories/not_published_repository.dart';
import '../datasources/not_published_remote_datasource.dart';

class NotPublishedRepositoryImpl implements NotPublishedRepository {
  final NotPublishedRemoteDataSource remoteDataSource;

  NotPublishedRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<NotPublishedEntity>> getAds() async {
    return await remoteDataSource.fetchAds();
  }
}
