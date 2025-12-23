import 'package:haraj_adan_app/features/ad_details/models/ad_details_model.dart';
import 'package:haraj_adan_app/features/ad_details/models/comment_model.dart';

abstract class AdDetailsRepository {
  Future<AdDetailsModel?> getAdDetails({
    required int adId,
    String? includes,
    int? userId,
  });

  Future<List<CommentModel>> getAdComments({
    required int adId,
    int page,
    int limit,
  });
}
