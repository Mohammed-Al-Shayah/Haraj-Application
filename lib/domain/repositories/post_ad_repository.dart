import 'dart:io';

abstract class PostAdRepository {
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
    Map<String, dynamic>? featured,
  });
}
