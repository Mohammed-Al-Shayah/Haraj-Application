import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/features/home/models/ads/ad_featured_history_model.dart';

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
  final String? ownerName;
  final String? ownerPhone;
  final int? ownerId;
  final List<AdFeaturedHistoryModel> featuredHistory;
  final bool? featuredFlag;

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
    this.ownerName,
    this.ownerPhone,
    this.ownerId,
    required this.featuredHistory,
    this.featuredFlag,
  });

  bool get isFeatured {
    if (featuredFlag == true) return true;
    if (featuredHistory.isEmpty) return false;
    final now = DateTime.now();
    for (final item in featuredHistory) {
      if (item.status && item.endDate.isAfter(now)) return true;
    }
    return false;
  }

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
    final int? likeId =
        isLiked
            ? (adLikes.first is Map
                ? (adLikes.first['id'] as num?)?.toInt()
                : null)
            : null;

    Map<String, dynamic>? extractUser(Map<String, dynamic> root) {
      const userKeys = [
        'user',
        'users',
        'owner',
        'owner_data',
        'advertiser',
        'creator',
        'created_by',
        'customer',
        'publisher',
      ];
      for (final key in userKeys) {
        final candidate = root[key];
        if (candidate is Map<String, dynamic>) return candidate;
      }
      return null;
    }

    String? extractOwnerName(Map<String, dynamic> root) {
      final user = extractUser(root);
      const nameKeys = [
        'name',
        'user_name',
        'username',
        'full_name',
        'first_name',
        'last_name',
      ];
      if (user != null) {
        for (final key in nameKeys) {
          final val = user[key];
          if (val != null && val.toString().trim().isNotEmpty) {
            return val.toString().trim();
          }
        }
        final fn = user['first_name']?.toString().trim() ?? '';
        final ln = user['last_name']?.toString().trim() ?? '';
        final combined =
            [fn, ln].where((e) => e.isNotEmpty).join(' ').trim();
        if (combined.isNotEmpty) return combined;
      }
      final rootName = root['user_name'] ?? root['owner_name'];
      if (rootName != null && rootName.toString().trim().isNotEmpty) {
        return rootName.toString().trim();
      }
      return null;
    }

    String? extractOwnerPhone(Map<String, dynamic> root) {
      final user = extractUser(root);
      const phoneKeys = [
        'phone',
        'mobile',
        'phone_number',
        'phoneNumber',
        'contact_phone',
        'whatsapp',
        'whats_app',
        'contact',
      ];
      if (user != null) {
        for (final key in phoneKeys) {
          final val = user[key];
          if (val != null && val.toString().trim().isNotEmpty) {
            return val.toString().trim();
          }
        }
      }
      for (final key in phoneKeys) {
        final val = root[key];
        if (val != null && val.toString().trim().isNotEmpty) {
          return val.toString().trim();
        }
      }
      return null;
    }

    int? extractOwnerId(Map<String, dynamic> root) {
      final user = extractUser(root);
      const idKeys = [
        'id',
        'user_id',
        'userId',
        'owner_id',
        'advertiser_id',
        'creator_id',
        'created_by',
        'customer_id',
        'publisher_id',
      ];
      if (user != null) {
        for (final key in idKeys) {
          final val = user[key];
          if (val is num) return val.toInt();
          final parsed = int.tryParse(val?.toString() ?? '');
          if (parsed != null) return parsed;
        }
      }
      for (final key in idKeys) {
        final val = root[key];
        if (val is num) return val.toInt();
        final parsed = int.tryParse(val?.toString() ?? '');
        if (parsed != null) return parsed;
      }
      return null;
    }

    List<AdFeaturedHistoryModel> extractFeaturedHistory(
      Map<String, dynamic> root,
    ) {
      final raw =
          root['ad_featured_history'] ??
          root['featured_history'] ??
          root['featured'];
      if (raw is bool) return const [];
      final list =
          raw is List
              ? raw
              : (raw is Map && raw['data'] is List ? raw['data'] as List : null);
      if (list == null) return const [];
      final out = <AdFeaturedHistoryModel>[];
      for (final item in list) {
        if (item is! Map<String, dynamic>) continue;
        try {
          out.add(AdFeaturedHistoryModel.fromJson(item));
        } catch (_) {
          // Ignore malformed featured items.
        }
      }
      return out;
    }

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
      ownerName: extractOwnerName(json),
      ownerPhone: extractOwnerPhone(json),
      ownerId: extractOwnerId(json),
      featuredHistory: extractFeaturedHistory(json),
      featuredFlag:
          (json['featured'] is bool)
              ? json['featured'] as bool
              : null,
    );
  }
}

class AdAttributeModel {
  final String label;
  final String labelEn;
  final List<String> values;
  final List<String> valuesEn;
  final String? typeCode;

  AdAttributeModel({
    required this.label,
    required this.labelEn,
    required this.values,
    required this.valuesEn,
    this.typeCode,
  });

  String displayLabel(bool isEn) {
    if (isEn && labelEn.isNotEmpty) return labelEn;
    if (!isEn && label.isNotEmpty) return label;
    return isEn ? labelEn : label;
  }

  String displayValue(bool isEn) {
    final list = isEn ? valuesEn : values;
    if (list.isNotEmpty) return list.join(', ');
    final fallback = isEn ? values : valuesEn;
    return fallback.isEmpty ? '-' : fallback.join(', ');
  }

  factory AdAttributeModel.fromJson(Map<String, dynamic> json) {
    final categoryAttr = json['category_attributes'] as Map<String, dynamic>?;
    final type =
        categoryAttr?['category_attributes_types'] as Map<String, dynamic>?;
    final values = <String>[];
    final valuesEn = <String>[];

    final options = json['ad_attribute_options'];
    if (options is List) {
      for (final item in options) {
        if (item is Map) {
          final val = item['category_attributes_values'];
          if (val is Map) {
            final name = val['name']?.toString();
            final nameEn = val['name_en']?.toString();
            if (name != null && name.isNotEmpty) values.add(name);
            if (nameEn != null && nameEn.isNotEmpty) {
              valuesEn.add(nameEn);
            } else if (name != null && name.isNotEmpty) {
              valuesEn.add(name);
            }
          }
        }
      }
    }

    final textValue = json['text']?.toString();
    if (textValue != null && textValue.isNotEmpty) {
      values.add(textValue);
      valuesEn.add(textValue);
    }
    final numberValue = json['number']?.toString();
    if (numberValue != null && numberValue.isNotEmpty) {
      values.add(numberValue);
      valuesEn.add(numberValue);
    }

    return AdAttributeModel(
      label: categoryAttr?['name']?.toString() ?? '',
      labelEn: categoryAttr?['name_en']?.toString() ?? '',
      values: values,
      valuesEn: valuesEn,
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
