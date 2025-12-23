import 'package:haraj_adan_app/data/datasources/ad_details_remote_data_source.dart';
import 'package:haraj_adan_app/domain/repositories/ad_details_repository.dart';
import 'package:haraj_adan_app/features/ad_details/models/ad_details_model.dart';
import 'package:haraj_adan_app/features/ad_details/models/comment_model.dart';

class AdDetailsRepositoryImpl implements AdDetailsRepository {
  final AdDetailsRemoteDataSource remote;

  AdDetailsRepositoryImpl(this.remote);

  @override
  Future<AdDetailsModel?> getAdDetails({
    required int adId,
    String? includes,
    int? userId,
  }) {
    return remote.fetchAdDetails(adId: adId, includes: includes, userId: userId);
  }

  @override
  Future<List<CommentModel>> getAdComments({
    required int adId,
    int page = 1,
    int limit = 10,
  }) {
    return remote.fetchComments(adId: adId, page: page, limit: limit);
  }
}
