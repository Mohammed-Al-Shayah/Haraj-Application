import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/features/subcategories/models/banner_model.dart';

class BannerApi {
  final Dio _dio = Dio();

  Future<List<BannerModel>> fetchBanners() async {
    try {
      final response = await _dio.get(ApiEndpoints.banners);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((json) => BannerModel.fromJson(json)).toList();
        }
      }

      return [];
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ Dio Error: ${e.response?.data ?? e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unknown Error: $e');
      }
      rethrow;
    }
  }
}
