import 'package:haraj_adan_app/domain/entities/comment_entity.dart';

abstract class CommentsRepository {
  Future<CommentsPageEntity> getComments({
    required int adId,
    int page,
    int limit,
  });

  Future<CommentEntity> createComment({
    required int adId,
    required int userId,
    required String text,
  });
}

class CommentsPageEntity {
  final List<CommentEntity> items;
  final int total;
  final int page;

  CommentsPageEntity({
    required this.items,
    required this.total,
    required this.page,
  });
}
