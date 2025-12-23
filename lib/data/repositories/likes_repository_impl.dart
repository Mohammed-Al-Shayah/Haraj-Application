
import 'package:haraj_adan_app/data/datasources/likes_remote_datasource.dart';
import 'package:haraj_adan_app/domain/repositories/likes_repository.dart';

class LikesRepositoryImpl implements LikesRepository {
  final LikesRemoteDataSource remote;
  LikesRepositoryImpl(this.remote);

  @override
  Future<int> likeAd({required int adId, required int userId}) {
    return remote.likeAd(adId: adId, userId: userId);
  }

  @override
  Future<void> removeLike({required int likeId}) {
    return remote.removeLike(likeId: likeId);
  }
}
