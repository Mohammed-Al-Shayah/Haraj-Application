import 'package:haraj_adan_app/data/datasources/comment_remote_data_source.dart';
import 'package:haraj_adan_app/domain/entities/comment_entity.dart';
import 'package:haraj_adan_app/domain/repositories/comment_repository.dart';

class CommentsRepositoryImpl implements CommentsRepository {
  final CommentsRemoteDataSource remote;

  CommentsRepositoryImpl(this.remote);

  @override
  Future<CommentsPageEntity> getComments({
    required int adId,
    int page = 1,
    int limit = 10,
  }) async {
    final res = await remote.getComments(adId: adId, page: page, limit: limit);

    return CommentsPageEntity(
      items:
          res.items.map((m) {
            return CommentEntity(
              id: m.id,
              text: m.text,
              created:
                  DateTime.tryParse(m.created) ??
                  DateTime.fromMillisecondsSinceEpoch(0),
              userId: m.id,
              userName: m.user!.name,
            );
          }).toList(),
      total: res.total,
      page: res.page,
    );
  }

  @override
  Future<CommentEntity> createComment({
    required int adId,
    required int userId,
    required String text,
  }) async {
    final m = await remote.createComment(
      adId: adId,
      userId: userId,
      text: text,
    );

    return CommentEntity(
      id: m.id,
      text: m.text.isNotEmpty ? m.text : text,
      created:
          DateTime.tryParse(m.created) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      userId: m.id,
      userName: m.user?.name ?? '',
    );
  }
}
