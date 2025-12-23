abstract class LikesRepository {
  Future<int> likeAd({required int adId, required int userId});
  Future<void> removeLike({required int likeId});
}
