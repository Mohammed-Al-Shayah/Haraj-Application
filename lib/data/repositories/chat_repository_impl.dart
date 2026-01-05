import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/paginated_result.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Future<PaginatedResult<ChatEntity>> getChats({
    required int userId,
    required int page,
    int limit = 10,
    String? search,
  }) async {
    final result = await remoteDataSource.fetchChats(
      userId: userId,
      page: page,
      limit: limit,
      search: search,
    );

    return PaginatedResult<ChatEntity>(
      items: result.items,
      page: result.page,
      hasMore: result.hasMore,
    );
  }
}
