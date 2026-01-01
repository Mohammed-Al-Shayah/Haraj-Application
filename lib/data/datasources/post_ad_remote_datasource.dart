import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';

abstract class PostAdRemoteDataSource {
  Future<List<dynamic>> getParentCategories();
  Future<Map<String, dynamic>> getCategoryAttributes(int categoryId);
  Future<Map<String, dynamic>> getFeaturedSettings();
  Future<List<dynamic>> getDiscounts();
  Future<Map<String, dynamic>> getAdForEdit(int adId);

  Future<Map<String, dynamic>> createAd({
    required int userId,
    required int categoryId,
    required String title,
    String? titleEn,
    required num price,
    required int currencyId,
    String? descr,
    required String lat,
    required String lng,
    required String address,
    required List<File> images,
    required List<Map<String, dynamic>> attributes,
    Map<String, dynamic>? featured, // {discount_id, status}
  });

  Future<Map<String, dynamic>> updateAd({
    required int adId,
    required int userId,
    required String title,
    String? titleEn,
    required num price,
    required int currencyId,
    required String lat,
    required String lng,
    required String address,
    required List<int> adCategories,
    required List<Map<String, dynamic>> attributes,
    List<int> removeImageIds,
    List<File> images,
  });

  Future<Map<String, dynamic>> featureAd(int adId, {int? userId});
  Future<Map<String, dynamic>> refundFeaturedAd(int adId);
}

class PostAdRemoteDataSourceImpl implements PostAdRemoteDataSource {
  final ApiClient api;
  PostAdRemoteDataSourceImpl(this.api);

  @override
  Future<List<dynamic>> getParentCategories() async {
    final res = await api.get(
      ApiEndpoints.categoriesParents,
      queryParams: {'includes': 'children'},
    );

    final data = res['data'];
    if (data is List) return data;
    if (data is Map<String, dynamic>) return <dynamic>[data];
    return <dynamic>[];
  }

  @override
  Future<Map<String, dynamic>> getCategoryAttributes(int categoryId) async {
    final res = await api.get(ApiEndpoints.categoryAttributes(categoryId));
    return (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
  }

  @override
  Future<Map<String, dynamic>> getFeaturedSettings() async {
    final res = await api.get(ApiEndpoints.featuredSettings);
    return (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
  }

  @override
  Future<List<dynamic>> getDiscounts() async {
    final res = await api.get(ApiEndpoints.discounts);
    return (res['data'] as List?) ?? [];
  }

  @override
  Future<Map<String, dynamic>> getAdForEdit(int adId) async {
    final res = await api.get(
      ApiEndpoints.adDetails(adId),
      queryParams: {'includes': 'images,attributes,ad_categories,categories'},
    );
    return (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
  }

  @override
  Future<Map<String, dynamic>> createAd({
    required int userId,
    required int categoryId,
    required String title,
    String? titleEn,
    required num price,
    required int currencyId,
    String? descr,
    required String lat,
    required String lng,
    required String address,
    required List<File> images,
    required List<Map<String, dynamic>> attributes,
    Map<String, dynamic>? featured,
  }) async {
    final form = FormData();

    // required fields
    form.fields.addAll([
      MapEntry('user_id', userId.toString()),
      MapEntry('title', title),
      MapEntry('price', price.toString()),
      MapEntry('currency_id', currencyId.toString()),
      MapEntry('lat', lat),
      MapEntry('lng', lng),
      MapEntry('address', address),
      // Must be JSON.stringified. :contentReference[oaicite:1]{index=1}
      MapEntry('ad_categories', _encodeJson(<int>[categoryId])),
      MapEntry('attributes', _encodeJson(attributes)),
    ]);

    if (titleEn != null && titleEn.trim().isNotEmpty) {
      form.fields.add(MapEntry('title_en', titleEn));
    }
    if (descr != null && descr.trim().isNotEmpty) {
      form.fields.add(MapEntry('descr', descr));
    }

    // optional featured
    if (featured != null) {
      form.fields.add(MapEntry('featured', _encodeJson(featured)));
    }

    // images (ads_images[])
    for (final file in images) {
      final fileName = file.path.split('/').last;
      form.files.add(
        MapEntry(
          'ads_images',
          await MultipartFile.fromFile(file.path, filename: fileName),
        ),
      );
    }

    final res = await api.post(
      ApiEndpoints.createAd,
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );

    return (res as Map).cast<String, dynamic>();
  }

  String _encodeJson(dynamic value) => jsonEncode(value);

  @override
  Future<Map<String, dynamic>> updateAd({
    required int adId,
    required int userId,
    required String title,
    String? titleEn,
    required num price,
    required int currencyId,
    required String lat,
    required String lng,
    required String address,
    required List<int> adCategories,
    required List<Map<String, dynamic>> attributes,
    List<int> removeImageIds = const [],
    List<File> images = const [],
  }) async {
    final form = FormData();

    form.fields.addAll([
      MapEntry('user_id', userId.toString()),
      MapEntry('title', title),
      MapEntry('price', price.toString()),
      MapEntry('currency_id', currencyId.toString()),
      MapEntry('lat', lat),
      MapEntry('lng', lng),
      MapEntry('address', address),
      MapEntry('ad_categories', _encodeJson(adCategories)),
      MapEntry('attributes', _encodeJson(attributes)),
    ]);

    if (titleEn != null && titleEn.trim().isNotEmpty) {
      form.fields.add(MapEntry('title_en', titleEn));
    }

    if (removeImageIds.isNotEmpty) {
      form.fields.add(
        MapEntry('remove_image_ids', _encodeJson(removeImageIds)),
      );
    }

    for (final file in images) {
      final fileName = file.path.split('/').last;
      form.files.add(
        MapEntry(
          'ads_images',
          await MultipartFile.fromFile(file.path, filename: fileName),
        ),
      );
    }

    final res = await api.patch(
      ApiEndpoints.updateAd(adId),
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );

    return (res as Map).cast<String, dynamic>();
  }

  @override
  Future<Map<String, dynamic>> featureAd(int adId, {int? userId}) async {
    final res = await api.patch(
      ApiEndpoints.featureAd(adId),
      data: userId != null ? {'user_id': userId} : null,
    );
    return (res as Map).cast<String, dynamic>();
  }

  @override
  Future<Map<String, dynamic>> refundFeaturedAd(int adId) async {
    final res = await api.patch(ApiEndpoints.refundFeaturedAd(adId));
    return (res as Map).cast<String, dynamic>();
  }
}
