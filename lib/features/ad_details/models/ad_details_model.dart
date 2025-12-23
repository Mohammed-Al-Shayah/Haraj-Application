import 'package:haraj_adan_app/core/network/endpoints.dart';

class AdDetailsModel {
  final int id;
  final String title;
  final String titleEn;
  final String price;
  final String address;
  final String? description;
  final List<String> images;
  final double latitude;
  final double longitude;
  final String? currencySymbol;
  final int likesCount;
  final bool isLiked;
  final int? likeId;
  final DateTime? createdAt;
  final String? categoryName;
  final String? categoryNameEn;
  final List<AdAttributeModel> attributes;

  AdDetailsModel({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.price,
    required this.address,
    required this.images,
    required this.latitude,
    required this.longitude,
    required this.attributes,
    this.description,
    this.currencySymbol,
    required this.likesCount,
    required this.isLiked,
    this.likeId,
    this.createdAt,
    this.categoryName,
    this.categoryNameEn,
  });

  factory AdDetailsModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0;

    List<String> extractImages(Map<String, dynamic> json) {
      final imgs = json['ads_images'];
      final List<String> out = [];
      if (imgs is List) {
        for (final item in imgs) {
          if (item is Map && item['image'] is String) {
            final raw = (item['image'] as String).trim();
            if (raw.isEmpty) continue;
            if (raw.startsWith('http')) {
              out.add(raw);
            } else {
              final sanitized = raw.replaceFirst(RegExp(r'^/+'), '');
              out.add('${ApiEndpoints.imageUrl}$sanitized');
            }
          }
        }
      }
      return out;
    }

    String? extractCategoryName(Map<String, dynamic> json, String key) {
      final category = json[key];
      if (category is Map) {
        return category['name']?.toString();
      }
      return null;
    }

    String? extractCategoryNameEn(Map<String, dynamic> json, String key) {
      final category = json[key];
      if (category is Map) {
        return category['name_en']?.toString();
      }
      return null;
    }

    int parseLikes(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    final adLikes = (json['ad_likes'] as List?) ?? const [];
    final bool isLiked = adLikes.isNotEmpty;
    final int? likeId = isLiked
        ? (adLikes.first is Map ? (adLikes.first['id'] as num?)?.toInt() : null)
        : null;

    return AdDetailsModel(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      titleEn: json['title_en']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      description: json['descr']?.toString(),
      images: extractImages(json),
      latitude: toDouble(json['lat']),
      longitude: toDouble(json['lng']),
      attributes: AdAttributeModel.fromList(json['ad_attributes']),
      createdAt: DateTime.tryParse(json['created']?.toString() ?? ''),
      categoryName:
          extractCategoryName(json, 'category') ??
          extractCategoryName(json, 'categories'),
      categoryNameEn:
          extractCategoryNameEn(json, 'category') ??
          extractCategoryNameEn(json, 'categories'),
      currencySymbol:
          json['currencies'] is Map
              ? json['currencies']['symbol']?.toString()
              : null,
      likesCount: parseLikes(json['likesCount'] ?? json['likes']),
      isLiked: isLiked,
      likeId: likeId,
    );
  }
}

class AdAttributeModel {
  final String label;
  final String labelEn;
  final List<String> values;
  final String? typeCode;

  AdAttributeModel({
    required this.label,
    required this.labelEn,
    required this.values,
    this.typeCode,
  });

  String displayLabel(bool isEn) {
    if (isEn && labelEn.isNotEmpty) return labelEn;
    if (!isEn && label.isNotEmpty) return label;
    return isEn ? labelEn : label;
  }

  String displayValue() {
    return values.isEmpty ? '-' : values.join(', ');
  }

  factory AdAttributeModel.fromJson(Map<String, dynamic> json) {
    final categoryAttr = json['category_attributes'] as Map<String, dynamic>?;
    final type =
        categoryAttr?['category_attributes_types'] as Map<String, dynamic>?;
    final values = <String>[];

    final options = json['ad_attribute_options'];
    if (options is List) {
      for (final item in options) {
        if (item is Map) {
          final val = item['category_attributes_values'];
          if (val is Map) {
            final name = val['name']?.toString() ?? val['name_en']?.toString();
            if (name != null && name.isNotEmpty) values.add(name);
          }
        }
      }
    }

    final textValue = json['text']?.toString();
    if (textValue != null && textValue.isNotEmpty) {
      values.add(textValue);
    }
    final numberValue = json['number']?.toString();
    if (numberValue != null && numberValue.isNotEmpty) {
      values.add(numberValue);
    }

    return AdAttributeModel(
      label: categoryAttr?['name']?.toString() ?? '',
      labelEn: categoryAttr?['name_en']?.toString() ?? '',
      values: values,
      typeCode: type?['code']?.toString(),
    );
  }

  static List<AdAttributeModel> fromList(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(AdAttributeModel.fromJson)
          .toList();
    }
    return [];
  }
}
