import 'package:haraj_adan_app/data/models/ad_model.dart';

/// Single-choice attribute selection (radio/select).
class AttributeSelection {
  final int attributeId;
  final int? attributeValueId;
  final String? value;

  const AttributeSelection({
    required this.attributeId,
    this.attributeValueId,
    this.value,
  });

  Map<String, dynamic> toJson() => {
        'attributeId': attributeId,
        if (attributeValueId != null) 'attributeValueId': attributeValueId,
        if (value != null && value!.trim().isNotEmpty) 'value': value,
      };
}

/// Multi-choice checkbox selection.
class CheckboxSelection {
  final int attributeId;
  final List<int> attributeValueIds;

  const CheckboxSelection({
    required this.attributeId,
    required this.attributeValueIds,
  });

  Map<String, dynamic> toJson() => {
        'attributeId': attributeId,
        'attributeValueIds': attributeValueIds,
      };
}

class FilterCategoryModel {
  final int id;
  final int? parentId;
  final String name;
  final String? nameEn;
  final String? image;
  final List<CategoryAttributeModel> attributes;

  const FilterCategoryModel({
    required this.id,
    required this.parentId,
    required this.name,
    required this.nameEn,
    required this.image,
    required this.attributes,
  });

  factory FilterCategoryModel.fromJson(Map<String, dynamic> json) {
    final attrs = json['category_attributes'];
    return FilterCategoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      parentId: (json['parent_id'] as num?)?.toInt(),
      name: json['name']?.toString() ?? '',
      nameEn: json['name_en']?.toString(),
      image: json['image']?.toString(),
      attributes: attrs is List
          ? attrs
              .whereType<Map<String, dynamic>>()
              .map(CategoryAttributeModel.fromJson)
              .toList()
          : const <CategoryAttributeModel>[],
    );
  }
}

class CategoryAttributeModel {
  final int id;
  final int categoryId;
  final String name;
  final String? nameEn;
  final String typeCode;
  final List<CategoryAttributeValueModel> values;

  const CategoryAttributeModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.nameEn,
    required this.typeCode,
    required this.values,
  });

  factory CategoryAttributeModel.fromJson(Map<String, dynamic> json) {
    final typeMap = json['category_attributes_types'];
    return CategoryAttributeModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      categoryId: (json['category_id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      nameEn: json['name_en']?.toString(),
      typeCode: typeMap is Map ? typeMap['code']?.toString() ?? '' : '',
      values: (json['category_attributes_values'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(CategoryAttributeValueModel.fromJson)
              .toList() ??
          const <CategoryAttributeValueModel>[],
    );
  }
}

class CategoryAttributeValueModel {
  final int id;
  final String name;
  final String? nameEn;

  const CategoryAttributeValueModel({
    required this.id,
    required this.name,
    required this.nameEn,
  });

  factory CategoryAttributeValueModel.fromJson(Map<String, dynamic> json) {
    return CategoryAttributeValueModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      nameEn: json['name_en']?.toString(),
    );
  }
}

class CurrencyModel {
  final int id;
  final String name;
  final String? nameEn;
  final String? symbol;

  const CurrencyModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.symbol,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      nameEn: json['name_en']?.toString(),
      symbol: json['symbol']?.toString(),
    );
  }
}

class AdsFilterMetaModel {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const AdsFilterMetaModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory AdsFilterMetaModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AdsFilterMetaModel(total: 0, page: 1, limit: 10, totalPages: 1);
    }

    return AdsFilterMetaModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

class AdsFilterResultModel {
  final List<AdModel> ads;
  final AdsFilterMetaModel meta;

  const AdsFilterResultModel({
    required this.ads,
    required this.meta,
  });
}
