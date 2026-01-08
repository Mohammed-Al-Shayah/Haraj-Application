import 'package:dio/dio.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/domain/entities/paginated_result.dart';
import '../models/support_chat_model.dart';
import '../models/support_message_model.dart';
import 'pagination_response_parser.dart';

abstract class SupportRemoteDataSource {
  Future<PaginatedResult<SupportChatModel>> fetchChats({
    required int page,
    int limit,
    String? search,
  });

  Future<PaginatedResult<SupportMessageModel>> fetchMessages({
    required int chatId,
    required int page,
    int limit,
  });

  Future<SupportMessageModel?> uploadMedia({
    required int chatId,
    required int userId,
    required String type,
    required String filePath,
    bool isAdmin = false,
  });
}

class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  final ApiClient apiClient;
  final PaginationResponseParser _parser;

  SupportRemoteDataSourceImpl(
    this.apiClient, {
    PaginationResponseParser? parser,
  }) : _parser = parser ?? const PaginationResponseParser();

  @override
  Future<PaginatedResult<SupportChatModel>> fetchChats({
    required int page,
    int limit = 10,
    String? search,
  }) async {
    final query = {
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    dynamic res;
    try {
      res = await apiClient.get(
        ApiEndpoints.supportChatsPaginate,
        queryParams: query,
      );
    } on Object {
      res = await apiClient.get(
        ApiEndpoints.supportChatsCustomerPaginate,
        queryParams: query,
      );
    }

    final list = _parser.extractList(res);
    final meta = _parser.extractMeta(res);

    final items =
        list
            .whereType<Map<String, dynamic>>()
            .map((e) => SupportChatModel.fromMap(e))
            .toList();

    final hasMore = _parser.hasMore(
      meta: meta,
      page: page,
      limit: limit,
      fetched: items.length,
    );

    return PaginatedResult<SupportChatModel>(
      items: items,
      page: page,
      hasMore: hasMore,
      meta: meta,
    );
  }

  @override
  Future<PaginatedResult<SupportMessageModel>> fetchMessages({
    required int chatId,
    required int page,
    int limit = 20,
  }) async {
    final res = await apiClient.get(
      ApiEndpoints.supportChatDetail(chatId),
      queryParams: {'page': page, 'limit': limit},
    );

    final list = _parser.extractList(
      res,
      nestedListKeys: const ['support_chat_messages'],
    );
    final meta = _parser.extractMeta(res);

    final items =
        list
            .whereType<Map<String, dynamic>>()
            .map((e) => SupportMessageModel.fromMap(e))
            .toList()
          ..sort((a, b) {
            final at = a.createdAt;
            final bt = b.createdAt;
            if (at != null && bt != null) {
              return bt.compareTo(at);
            }
            if (a.id != null && b.id != null) {
              return b.id!.compareTo(a.id!);
            }
            return 0;
          });

    final hasMore = _parser.hasMore(
      meta: meta,
      page: page,
      limit: limit,
      fetched: items.length,
    );

    return PaginatedResult<SupportMessageModel>(
      items: items,
      page: page,
      hasMore: hasMore,
      meta: meta,
    );
  }

  @override
  Future<SupportMessageModel?> uploadMedia({
    required int chatId,
    required int userId,
    required String type,
    required String filePath,
    bool isAdmin = false,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'chatId': chatId,
      'type': type,
      'userId': userId,
      'is_admin': isAdmin ? 1 : 0,
    });

    final res = await apiClient.post(
      ApiEndpoints.supportChatMedia,
      data: formData,
      isMultipart: true,
    );

    final data = _parser.extractData(res);
    if (data is Map<String, dynamic>) {
      return SupportMessageModel.fromMap(data);
    }
    return null;
  }
}
