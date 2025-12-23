import '../../domain/entities/featured_ad_entity.dart';

class FeaturedAdModel {
  final String id;
  final String imageUrl;
  final String title;
  final bool isFeatured;

  FeaturedAdModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    this.isFeatured = false,
  });

  factory FeaturedAdModel.fromJson(Map<String, dynamic> json) {
    return FeaturedAdModel(
      id: json['id'],
      imageUrl: json['imageUrl'],
      title: json['title'],
      isFeatured: json['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'isFeatured': isFeatured,
    };
  }

  FeaturedAdEntity toEntity() {
    return FeaturedAdEntity(
      id: id,
      imageUrl: imageUrl,
      title: title,
      isFeatured: isFeatured,
    );
  }
}
