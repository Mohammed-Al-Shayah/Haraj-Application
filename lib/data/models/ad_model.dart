import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/domain/entities/ad_entity.dart';

class AdModel extends AdEntity {
  AdModel({
    required super.id,
    required super.imageUrl,
    required super.title,
    required super.location,
    required super.price,
    required super.likesCount,
    required super.commentsCount,
    required super.createdAt,
    required super.latitude,
    required super.longitude,
    super.currencySymbol,
    required super.isLiked,
    required super.likeId,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) =>
        v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));

    String? extractImage(Map<String, dynamic> json) {
      final images = json['ads_images'];
      String? image;
      if (images is List && images.isNotEmpty) {
        final first = images.first;
        if (first is Map && first['image'] is String) {
          image = first['image'] as String;
        } else if (first is String) {
          image = first;
        }
      }
      if (json['imageUrl'] is String) image ??= json['imageUrl'] as String;
      if (json['image'] is String) image ??= json['image'] as String;

      if (image != null && image.isNotEmpty && !image.toLowerCase().startsWith('http')) {
        return '${ApiEndpoints.imageUrl}$image';
      }
      return image ?? '';
    }

    final adLikes = (json['ad_likes'] as List?) ?? const [];
    final bool isLiked = adLikes.isNotEmpty;
    final int? likeId = isLiked
        ? (adLikes.first is Map ? (adLikes.first['id'] as num?)?.toInt() : null)
        : null;

    return AdModel(
      id: json['id'] ?? 0,
      imageUrl: extractImage(json) ?? '',
      title: json['title']?.toString() ?? '',
      location: json['address']?.toString() ?? json['location']?.toString() ?? '',
      price: toDouble(json['price']) ?? 0,

      likesCount: (json['likesCount'] ?? json['likes'] ?? 0) as int,
      commentsCount: (json['commentsCount'] ?? json['comments'] ?? 0) as int,

      createdAt: json['created']?.toString() ?? json['createdAt']?.toString() ?? '',
      latitude: toDouble(json['lat'] ?? json['latitude']) ?? 0,
      longitude: toDouble(json['lng'] ?? json['longitude']) ?? 0,
      currencySymbol: json['currencies'] is Map ? json['currencies']['symbol']?.toString() : null,

      // ✅ جديد
      isLiked: isLiked,
      likeId: likeId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'imageUrl': imageUrl,
        'title': title,
        'location': location,
        'price': price,
        'likesCount': likesCount,
        'commentsCount': commentsCount,
        'createdAt': createdAt,
        'latitude': latitude,
        'longitude': longitude,
        'isLiked': isLiked,
        'likeId': likeId,
      };
}
