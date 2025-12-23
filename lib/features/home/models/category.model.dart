class CategoryModel {
  final int id;
  final String name;
  final String nameEn;
  final String image;
  final int adsCount;
  final List<CategoryModel> children;

  CategoryModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.image,
    required this.adsCount,
    required this.children,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? '',
      image: json['image'] ?? '',
      adsCount: json['adsCount'] ?? 0,
      children: (json['children'] as List?)
          ?.map((child) => CategoryModel.fromJson(child))
          .toList() ??
          [],
    );
  }
}
