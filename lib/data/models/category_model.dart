import 'package:haraj_adan_app/core/network/endpoints.dart';
import '../../domain/entities/category_entity.dart';

class CategoryModel {
  final int? parentId;
  final int id;
  final String title;
  final String iconPath;
  final String name;
  final String nameEn;
  final int adsCount;
  final List<CategoryModel> children;
  final List<SubCategoryModel> subCategories;
  final String? exclusiveOfferCover;

  const CategoryModel({
    this.parentId,
    required this.id,
    required this.title,
    required this.iconPath,
    required this.name,
    required this.nameEn,
    required this.adsCount,
    this.children = const [],
    this.subCategories = const [],
    this.exclusiveOfferCover,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image']?.toString() ?? '';
    final fullImage =
        rawImage.isNotEmpty && !rawImage.toLowerCase().startsWith('http')
            ? '${ApiEndpoints.imageUrl}$rawImage'
            : rawImage;

    final children = json['children'] is List ? json['children'] as List : [];

    return CategoryModel(
      parentId: (json['parent_id'] is num)
          ? (json['parent_id'] as num).toInt()
          : (json['parent_id'] == null
              ? null
              : int.tryParse(json['parent_id'].toString())),
      id: json['id'] ?? 0,
      title: json['name'] ?? json['title'] ?? '',
      name: json['name']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      adsCount: json['adsCount'] is int ? json['adsCount'] as int : 0,
      iconPath: fullImage,
      children: children
          .whereType<Map<String, dynamic>>()
          .map(CategoryModel.fromJson)
          .toList(),
      subCategories: children
          .whereType<Map<String, dynamic>>()
          .map(SubCategoryModel.fromJson)
          .toList(),
      exclusiveOfferCover: json['exclusiveOfferCover']?.toString(),
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      title: title,
      titleEn: nameEn,
      iconPath: iconPath,
      subCategories: subCategories.map((e) => e.toEntity()).toList(),
      exclusiveOfferCover: exclusiveOfferCover,
    );
  }
}

class SubCategoryModel {
  final int? parentId;
  final int id;
  final String title;
  final String titleEn;
  final int adsCount;
  final List<SubSubCategoryModel> subSubCategories;

  const SubCategoryModel({
    required this.id,
    this.parentId,
    required this.title,
    required this.titleEn,
    this.adsCount = 0,
    this.subSubCategories = const [],
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    final children = json['children'] is List ? json['children'] as List : [];

    return SubCategoryModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      parentId: (json['parent_id'] is num)
          ? (json['parent_id'] as num).toInt()
          : (json['parent_id'] == null
              ? null
              : int.tryParse(json['parent_id'].toString())),
      title: json['name']?.toString() ?? json['title']?.toString() ?? '',
      titleEn: json['name_en']?.toString() ?? '',
      adsCount: json['adsCount'] is num ? (json['adsCount'] as num).toInt() : 0,
      subSubCategories: children
          .whereType<Map<String, dynamic>>()
          .map(SubSubCategoryModel.fromJson)
          .toList(),
    );
  }

  SubCategoryEntity toEntity() {
    return SubCategoryEntity(
      id: id,
      title: title,
      titleEn: titleEn,
      adsCount: adsCount,
      subSubCategories: subSubCategories.map((e) => e.toEntity()).toList(),
    );
  }
}

class SubSubCategoryModel {
  final int id;
  final String title;
  final String titleEn;

  const SubSubCategoryModel({
    required this.id,
    required this.title,
    required this.titleEn,
  });

  factory SubSubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubSubCategoryModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      title: json['name']?.toString() ?? json['title']?.toString() ?? '',
      titleEn: json['name_en']?.toString() ?? '',
    );
  }

  SubSubCategoryEntity toEntity() {
    return SubSubCategoryEntity(id: id, title: title, titleEn: titleEn);
  }
}
