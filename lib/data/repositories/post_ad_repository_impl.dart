import 'dart:io';

import 'package:haraj_adan_app/data/datasources/post_ad_remote_datasource.dart';
import 'package:haraj_adan_app/domain/repositories/post_ad_repository.dart';

class PostAdRepositoryImpl implements PostAdRepository {
  final PostAdRemoteDataSource remote;
  PostAdRepositoryImpl(this.remote);

  @override
  Future<List<dynamic>> getParentCategories() => remote.getParentCategories();

  @override
  Future<Map<String, dynamic>> getCategoryAttributes(int categoryId) =>
      remote.getCategoryAttributes(categoryId);

  @override
  Future<Map<String, dynamic>> getFeaturedSettings() => remote.getFeaturedSettings();

  @override
  Future<List<dynamic>> getDiscounts() => remote.getDiscounts();

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
    return remote.createAd(
      userId: userId,
      categoryId: categoryId,
      title: title,
      titleEn: titleEn,
      price: price,
      currencyId: currencyId,
      descr: descr,
      lat: lat,
      lng: lng,
      address: address,
      images: images,
      attributes: attributes,
      featured: featured,
    );
  }
}
