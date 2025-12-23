import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/features/home/models/category.model.dart';

class CategoriesRepository {
  final ApiClient _apiClient;

  CategoriesRepository(this._apiClient);

  Future<List<CategoryModel>> getAllCategories() async {
    final res = await _apiClient.get(ApiEndpoints.categoriesHome);
    final list = _extractList(res);
    return list.whereType<Map<String, dynamic>>().map(_mapCategory).toList();
  }

  List<dynamic> _extractList(dynamic res) {
    if (res is Map && res['data'] is List) {
      return List<dynamic>.from(res['data'] as List);
    }
    if (res is List) {
      return List<dynamic>.from(res);
    }
    return <dynamic>[];
  }

  CategoryModel _mapCategory(Map<String, dynamic> json) {
    final children = json['children'] is List ? json['children'] as List : [];
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? '',
      image: json['image']?.toString() ?? '',
      adsCount: json['adsCount'] ?? 0,
      children:
          children.whereType<Map<String, dynamic>>().map(_mapCategory).toList(),
    );
  }
}
