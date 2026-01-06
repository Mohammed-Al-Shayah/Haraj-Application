typedef JsonMap = Map<String, dynamic>;

class PaginationResponseParser {
  const PaginationResponseParser();

  List<dynamic> extractList(dynamic res, {List<String> nestedListKeys = const []}) {
    if (res is JsonMap) {
      final data = res['data'];
      if (data is List) return data;

      if (data is Map) {
        if (data['data'] is List) return data['data'] as List;

        // Support APIs sometimes use support_chat_messages
        for (final k in nestedListKeys) {
          if (data[k] is List) return data[k] as List;
        }
      }
    }
    if (res is List) return res;
    return const [];
  }

  JsonMap? extractMeta(dynamic res) {
    if (res is JsonMap) {
      if (res['meta'] is JsonMap) return res['meta'] as JsonMap;

      final data = res['data'];
      if (data is Map && data['meta'] is JsonMap) {
        return data['meta'] as JsonMap;
      }

      if (res['current_page'] != null || res['last_page'] != null) {
        return res;
      }
    }
    return null;
  }

  dynamic extractData(dynamic res) {
    if (res is JsonMap) {
      return res['data'] ?? res['result'] ?? res;
    }
    return res;
  }

  bool hasMore({
    required JsonMap? meta,
    required int page,
    required int limit,
    required int fetched,
  }) {
    if (meta == null) return fetched >= limit;

    final total = meta['total'];
    if (total is num) {
      return (page * limit) < total.toInt();
    }

    final lastPage = meta['last_page'];
    if (lastPage is num) {
      return page < lastPage.toInt();
    }

    final nextPageUrl = meta['next_page_url'];
    if (nextPageUrl is String) {
      return nextPageUrl.isNotEmpty;
    }

    
    return fetched >= limit;
  }
}
