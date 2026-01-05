import 'package:haraj_adan_app/domain/entities/paginated_result.dart';
import 'package:haraj_adan_app/domain/entities/support_chat_entity.dart';
import 'package:haraj_adan_app/domain/entities/support_message_entity.dart';
import 'package:haraj_adan_app/domain/repositories/support_repository.dart';
import '../datasources/support_remote_data_source.dart';

class SupportRepositoryImpl implements SupportRepository {
  final SupportRemoteDataSource remote;

  SupportRepositoryImpl(this.remote);

  @override
  Future<PaginatedResult<SupportChatEntity>> getChats({
    required int page,
    int limit = 10,
    String? search,
    int? userId,
  }) async {
    final result = await remote.fetchChats(
      page: page,
      limit: limit,
      search: search,
      userId: userId,
    );
    return PaginatedResult<SupportChatEntity>(
      items: result.items,
      page: result.page,
      hasMore: result.hasMore,
    );
  }

  @override
  Future<PaginatedResult<SupportMessageEntity>> getMessages({
    required int chatId,
    required int page,
    int limit = 20,
  }) async {
    final result = await remote.fetchMessages(
      chatId: chatId,
      page: page,
      limit: limit,
    );
    return PaginatedResult<SupportMessageEntity>(
      items: result.items,
      page: result.page,
      hasMore: result.hasMore,
    );
  }

  // @override
  // Future<SupportMessageEntity?> sendText({
  //   required int chatId,
  //   required int userId,
  //   required String message,
  //   bool isAdmin = false,
  // }) {
  //   return remote.sendText(
  //     chatId: chatId,
  //     userId: userId,
  //     message: message,
  //     isAdmin: isAdmin,
  //   );
  // }

  @override
  Future<SupportMessageEntity?> uploadMedia({
    required int chatId,
    required int userId,
    required String type,
    required String filePath,
    bool isAdmin = false,
  }) {
    return remote.uploadMedia(
      chatId: chatId,
      userId: userId,
      type: type,
      filePath: filePath,
      isAdmin: isAdmin,
    );
  }
}
