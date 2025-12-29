class CategoryEntity {
  final int id;
  final String title;
  final String titleEn;
  final String iconPath;
  final List<SubCategoryEntity> subCategories;
  final String? exclusiveOfferCover;

  CategoryEntity({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.iconPath,
    required this.subCategories,
    this.exclusiveOfferCover,
  });

  String get subTitle {
    final full = subCategories.map((e) => e.title).join(', ');
    return full.length > 25 ? '${full.substring(0, 25)}...' : full;
  }
}

class SubCategoryEntity {
  final int id;
  final String title;
  final String? titleEn;
  final int adsCount;
  final List<SubSubCategoryEntity> subSubCategories;

  SubCategoryEntity({
    required this.id,
    required this.title,
    this.titleEn,
    this.adsCount = 0,
    this.subSubCategories = const [],
  });
}

class SubSubCategoryEntity {
  final int id;
  final String title;
  final String? titleEn;

  SubSubCategoryEntity({
    required this.id,
    required this.title,
    this.titleEn,
  });
}
