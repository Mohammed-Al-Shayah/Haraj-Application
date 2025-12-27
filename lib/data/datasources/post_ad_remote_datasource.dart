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

    // API can return either List or Map. We normalize it to List.
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
}
