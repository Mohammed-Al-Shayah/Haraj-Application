import 'package:haraj_adan_app/core/network/endpoints.dart';
import '../../domain/entities/category_entity.dart';

class CategoryModel {
  final int id;
  final String title;
  final String iconPath;
  final String name;
  final String nameEn;
  final List<CategoryModel> children;
  final List<SubCategoryModel> subCategories;
  final String? exclusiveOfferCover;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.iconPath,
    required this.name,
    required this.nameEn,
    this.children = const [],
    required this.subCategories,
    this.exclusiveOfferCover,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image']?.toString() ?? '';
    final fullImage = rawImage.isNotEmpty &&
            !rawImage.toLowerCase().startsWith('http')
        ? '${ApiEndpoints.imageUrl}$rawImage'
        : rawImage;

    final children = json['children'] is List ? json['children'] as List : [];

    return CategoryModel(
      id: json['id'] ?? 0,
      title: json['name'] ?? json['title'] ?? '',
      name: json['name']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
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

  CategoryEntity toEntity() => CategoryEntity(
        id: id,
        title: title,
        iconPath: iconPath,
        subCategories: subCategories.map((e) => e.toEntity()).toList(),
        exclusiveOfferCover: exclusiveOfferCover,
      );
}

class SubCategoryModel {
  final int id;
  final String title;
  final List<SubSubCategoryModel> subSubCategories;

  const SubCategoryModel({
    required this.id,
    required this.title,
    this.subSubCategories = const [],
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    final children = json['children'] is List ? json['children'] as List : [];
    return SubCategoryModel(
      id: json['id'] ?? 0,
      title: json['name'] ?? json['title'] ?? '',
      subSubCategories: children
          .whereType<Map<String, dynamic>>()
          .map(SubSubCategoryModel.fromJson)
          .toList(),
    );
  }

  SubCategoryEntity toEntity() => SubCategoryEntity(
        id: id,
        title: title,
        subSubCategories: subSubCategories.map((e) => e.toEntity()).toList(),
      );
}

class SubSubCategoryModel {
  final int id;
  final String title;

  const SubSubCategoryModel({
    required this.id,
    required this.title,
  });

  factory SubSubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubSubCategoryModel(
      id: json['id'] ?? 0,
      title: json['name'] ?? json['title'] ?? '',
    );
  }

  SubSubCategoryEntity toEntity() => SubSubCategoryEntity(id: id, title: title);
}
