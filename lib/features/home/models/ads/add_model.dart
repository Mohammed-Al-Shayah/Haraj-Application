import 'package:haraj_adan_app/features/home/models/ads/ad_attribute_model.dart';
import 'package:haraj_adan_app/features/home/models/ads/ad_featured_history_model.dart';
import 'package:haraj_adan_app/features/home/models/ads/ad_image_model.dart';

class AdModel {
  final int id;
  final int userId;
  final String title;
  final String titleEn;
  final String price;
  final String address;
  final double latitude;
  final double longitude;
  final double? distance;
  final String? currencySymbol;
  final DateTime? created;
  final DateTime? updated;
  final List<AdFeaturedHistoryModel> featuredHistory;
  final List<AdImageModel> images;
  final List<AdAttributeModel> attributes;

  AdModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.titleEn,
    required this.price,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.distance,
    this.currencySymbol,
    required this.created,
    required this.updated,
    required this.featuredHistory,
    required this.images,
    required this.attributes,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) =>
        v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));

    return AdModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      title: json['title'] ?? '',
      titleEn: json['title_en'] ?? '',
      price: json['price']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: toDouble(json['lat']) ?? 0,
      longitude: toDouble(json['lng']) ?? 0,
      distance: toDouble(json['distance']),
      currencySymbol: json['currencies'] is Map
          ? json['currencies']['symbol']?.toString()
          : null,
      created:
          json['created'] != null ? DateTime.tryParse(json['created']) : null,
      updated:
          json['updated'] != null ? DateTime.tryParse(json['updated']) : null,
      featuredHistory:
          (json['ad_featured_history'] as List<dynamic>?)
              ?.map((e) => AdFeaturedHistoryModel.fromJson(e))
              .toList() ??
          [],
      images:
          (json['ads_images'] as List<dynamic>?)
              ?.map((e) => AdImageModel.fromJson(e))
              .toList() ??
          [],
      attributes:
          (json['ad_attributes'] as List<dynamic>?)
              ?.map((e) => AdAttributeModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
