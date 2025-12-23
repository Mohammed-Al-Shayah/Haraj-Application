class CommentModel {
  final int id;
  final String text;
  final String created;
  final UserModel? user;

  CommentModel({
    required this.id,
    required this.text,
    required this.created,
    this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return CommentModel(id: 0, text: '', created: '', user: null);
    }

    final rawText =
        json['text'] ??
        json['comment'] ??
        json['body'] ??
        json['content'] ??
        '';
    final rawCreated =
        json['created'] ?? json['created_at'] ?? json['createdAt'] ?? '';
    final rawUser = json['users'] ?? json['user'] ?? json['author'];

    return CommentModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      text: rawText?.toString() ?? '',
      created: rawCreated?.toString() ?? '',
      user:
          rawUser is Map
              ? UserModel.fromJson(Map<String, dynamic>.from(rawUser))
              : null,
    );
  }
}

class UserModel {
  final int id;
  final String name;

  UserModel({required this.id, required this.name});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawName =
        json['name'] ??
        json['username'] ??
        json['full_name'] ??
        json['fullName'] ??
        '';

    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: rawName?.toString() ?? '',
    );
  }
}

class CommentsPageModel {
  final List<CommentModel> items;
  final int total;
  final int page;

  CommentsPageModel({
    required this.items,
    required this.total,
    required this.page,
  });

  factory CommentsPageModel.fromJson(Map<String, dynamic> json) {
    // Some endpoints wrap data inside {data: {data: [...], total: ..., page: ...}}
    final rootData = json['data'];
    final listSource =
        rootData is List
            ? rootData
            : (rootData is Map ? rootData['data'] : json['items']);
    final data = listSource as List? ?? [];

    final metaRaw =
        json['meta'] ??
        (rootData is Map ? rootData['meta'] : null) ??
        (json['pagination']);
    final meta = metaRaw is Map ? metaRaw : {};

    return CommentsPageModel(
      items:
          data
              .whereType<Map>()
              .map((e) => CommentModel.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
      total:
          meta['total'] is int
              ? meta['total']
              : int.tryParse('${meta['total']}') ??
                  (rootData is Map && rootData['total'] is int
                      ? rootData['total']
                      : data.length),
      page:
          meta['page'] is int
              ? meta['page']
              : int.tryParse('${meta['page']}') ??
                  (rootData is Map && rootData['page'] is int
                      ? rootData['page']
                      : 1),
    );
  }
}
