import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/data/models/ad_model.dart';
import 'package:haraj_adan_app/data/models/search_filter_models.dart';

abstract class AdsRemoteDataSource {
  Future<AdsFilterResultModel> getAds({
    String? search,
    int? categoryId,
    int? subCategoryId,
    int? subSubCategoryId,
    double? minPrice,
    double? maxPrice,
    int? currencyId,
    String? sortBy,
    int page = 1,
    int limit = 10,
    List<AttributeSelection> attributes = const [],
    List<CheckboxSelection> checkboxes = const [],
  });
}

class AdsRemoteDataSourceImpl implements AdsRemoteDataSource {
  final ApiClient apiClient;

  AdsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AdsFilterResultModel> getAds({
    String? search,
    int? categoryId,
    int? subCategoryId,
    int? subSubCategoryId,
    double? minPrice,
    double? maxPrice,
    int? currencyId,
    String? sortBy,
    int page = 1,
    int limit = 10,
    List<AttributeSelection> attributes = const [],
    List<CheckboxSelection> checkboxes = const [],
  }) async {
    final effectiveCategoryId = subSubCategoryId ?? subCategoryId ?? categoryId;
    final payload = <String, dynamic>{
      if (effectiveCategoryId != null) 'category_id': effectiveCategoryId,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (currencyId != null) 'currency_id': currencyId,
      if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortBy,
      'page': page,
      'limit': limit,
    };

    if (attributes.isNotEmpty) {
      payload['attributes'] = attributes.map((e) => e.toJson()).toList();
    }
    if (checkboxes.isNotEmpty) {
      payload['checkboxes'] = checkboxes.map((e) => e.toJson()).toList();
    }

    payload.removeWhere(
      (key, value) => value == null || (value is List && value.isEmpty),
    );

    final response = await apiClient.post(
      ApiEndpoints.filterAds,
      data: payload,
    );

    final List<dynamic> list = _extractList(response);
    final ads =
        list
            .whereType<Map<String, dynamic>>()
            .map(_mapToAdModel)
            .whereType<AdModel>()
            .toList();

    final meta = _extractMeta(response);
    return AdsFilterResultModel(
      ads: ads,
      meta: AdsFilterMetaModel.fromJson(meta),
    );
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

  Map<String, dynamic>? _extractMeta(dynamic response) {
    if (response is Map<String, dynamic>) {
      final meta = response['meta'];
      if (meta is Map<String, dynamic>) return meta;
    }
    return null;
  }

  AdModel? _mapToAdModel(Map<String, dynamic> json) {
    try {
      final image = _extractImage(json);
      final latitude = _toDouble(json['latitude'] ?? json['lat']) ?? 0;
      final longitude = _toDouble(json['longitude'] ?? json['lng']) ?? 0;
      int toInt(dynamic v) {
        if (v == null) return 0;
        if (v is num) return v.toInt();
        return int.tryParse(v.toString()) ?? 0;
      }

      return AdModel(
        id: json['id'] ?? 0,
        imageUrl: image ?? '',
        title: json['title'] ?? json['name'] ?? '',
        location: json['location'] ?? json['address'] ?? '',
        price: _toDouble(json['price']) ?? 0,
        likesCount: toInt(
          json['likesCount'] ?? json['likes'] ?? json['likes_count'],
        ),
        commentsCount: toInt(
          json['commentsCount'] ?? json['comments'] ?? json['comments_count'],
        ),
        createdAt:
            (json['created'] ?? json['createdAt'] ?? json['created_at'])
                ?.toString() ??
            '',
        latitude: latitude,
        longitude: longitude,
        currencySymbol: _extractCurrencySymbol(json),
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

  String? _extractCurrencySymbol(Map<String, dynamic> json) {
    if (json['currency_symbol'] != null) {
      return json['currency_symbol'].toString();
    }
    final currencies = json['currencies'];
    if (currencies is Map && currencies['symbol'] != null) {
      return currencies['symbol'].toString();
    }
    return null;
  }
}
