import 'package:haraj_adan_app/core/network/endpoints.dart';

class CategoryModel {
  final int id;
  final int? parentId;
  final String name;
  final String nameEn;
  final String image;
  final int adsCount; 
  final List<CategoryModel> children;

  const CategoryModel({
    required this.id,
    required this.parentId,
    required this.name,
    required this.nameEn,
    required this.image,
    this.adsCount = 0, 
    this.children = const [],
  });

  // Backward compatibility
  String get title => name;

  bool get isRoot => parentId == null;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image']?.toString() ?? '';
    final imageUrl =
        rawImage.isNotEmpty && !rawImage.startsWith('http')
            ? '${ApiEndpoints.imageUrl}$rawImage'
            : rawImage;

    final List<dynamic> childrenJson =
        json['children'] is List ? json['children'] : [];

    return CategoryModel(
      id: (json['id'] as num).toInt(),
      parentId: json['parent_id'] == null
          ? null
          : (json['parent_id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      image: imageUrl,
      adsCount: json['adsCount'] is num
          ? (json['adsCount'] as num).toInt()
          : 0, // ✅ safe parse
      children: childrenJson
          .whereType<Map<String, dynamic>>()
          .map(CategoryModel.fromJson)
          .toList(),
    );
  }
}
