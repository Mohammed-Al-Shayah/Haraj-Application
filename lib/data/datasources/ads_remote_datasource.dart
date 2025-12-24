import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/data/models/ad_model.dart';

abstract class AdsRemoteDataSource {
  Future<List<AdModel>> getAds(
    String query, {
    int? categoryId,
    int? subCategoryId,
    int? subSubCategoryId,
  });
}

class AdsRemoteDataSourceImpl implements AdsRemoteDataSource {
  final ApiClient apiClient;

  AdsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<AdModel>> getAds(
    String query, {
    int? categoryId,
    int? subCategoryId,
    int? subSubCategoryId,
  }) async {
    final params = <String, dynamic>{};
    if (query.isNotEmpty) params['search'] = query;

    // Pick the most specific category id available.
    final effectiveCategoryId = subSubCategoryId ?? subCategoryId ?? categoryId;

    // Use category ads endpoint when category is known; fallback to /ads otherwise.
    final String endpoint =
        effectiveCategoryId != null
            ? ApiEndpoints.categoryAds(effectiveCategoryId)
            : ApiEndpoints.createAd;

    if (effectiveCategoryId != null) {
      params['includeChildren'] = 0;
      params['page'] = 0;
      params['limit'] = 0;
    }

    final response = await apiClient.get(
      endpoint,
      queryParams: params.isEmpty ? null : params,
    );

    final List<dynamic> list = _extractList(response);

    return list
        .whereType<Map<String, dynamic>>()
        .map(_mapToAdModel)
        .whereType<AdModel>()
        .toList();
  }

  List<dynamic> _extractList(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is List) return List<dynamic>.from(data);
      if (data is Map && data['ads'] is List) {
        return List<dynamic>.from(data['ads'] as List);
      }
      return const <dynamic>[];
    }

    if (response is List) return List<dynamic>.from(response);

    return const <dynamic>[];
  }

  AdModel? _mapToAdModel(Map<String, dynamic> json) {
    try {
      final image = _extractImage(json);
      final latitude = _toDouble(json['latitude'] ?? json['lat']) ?? 0;
      final longitude = _toDouble(json['longitude'] ?? json['lng']) ?? 0;

      return AdModel(
        id: json['id'] ?? 0,
        imageUrl: image ?? '',
        title: json['title'] ?? json['name'] ?? '',
        location: json['location'] ?? json['address'] ?? '',
        price: _toDouble(json['price']) ?? 0,
        likesCount: json['likesCount'] ?? json['likes'] ?? 0,
        commentsCount: json['commentsCount'] ?? json['comments'] ?? 0,
        createdAt: (json['createdAt'] ?? json['created_at'])?.toString() ?? '',
        latitude: latitude,
        longitude: longitude,
        isLiked: false,
        likeId: null,
      );
    } catch (_) {
      return null;
    }
  }

  String? _extractImage(Map<String, dynamic> json) {
    String? image;

    if (json['imageUrl'] is String) image = json['imageUrl'];
    if (json['image'] is String) image ??= json['image'];

    final images = json['ads_images'] ?? json['images'];
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      if (first is Map && first['image'] is String) image ??= first['image'];
      if (first is String) image ??= first;
    }

    if (image != null &&
        image.isNotEmpty &&
        !image.toLowerCase().startsWith('http')) {
      return '${ApiEndpoints.imageUrl}$image';
    }

    return image;
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
