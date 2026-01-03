import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/domain/entities/user_featured_ad_entity.dart';

class UserFeaturedAdModel extends UserFeaturedAdEntity {
  UserFeaturedAdModel({
    required super.id,
    required super.title,
    required super.location,
    required super.price,
    required super.imageUrl,
    super.status,
    super.latitude,
    super.longitude,
    super.currencySymbol,
  });

  factory UserFeaturedAdModel.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    String image(Map<String, dynamic> data) {
      String? image = data['image']?.toString();
      final images = data['ads_images'];
      if (images is List && images.isNotEmpty) {
        final first = images.first;
        if (first is Map && first['image'] is String) {
          image = first['image'] as String;
        } else if (first is String) {
          image = first;
        }
      }

      if (image != null &&
          image.isNotEmpty &&
          !image.toLowerCase().startsWith('http')) {
        return '${ApiEndpoints.imageUrl}$image';
      }
      return image ?? '';
    }

    return UserFeaturedAdModel(
      id:
          json['id'] is int
              ? json['id'] as int
              : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      location:
          json['location']?.toString() ?? json['address']?.toString() ?? '',
      price: (toDouble(json['price']) ?? json['price'] ?? '').toString(),
      imageUrl: image(json),
      status: json['status']?.toString(),
      latitude: toDouble(json['latitude'] ?? json['lat']),
      longitude: toDouble(json['longitude'] ?? json['lng']),
      currencySymbol: _currencySymbol(json),
    );
  }

  static String? _currencySymbol(Map<String, dynamic> json) {
    final currencies = json['currencies'];
    if (currencies is Map) {
      final symbol = currencies['symbol'] ?? currencies['currency_symbol'];
      if (symbol != null) return symbol.toString();
    }
    if (json['currency_symbol'] != null) {
      return json['currency_symbol'].toString();
    }
    return null;
  }
}
