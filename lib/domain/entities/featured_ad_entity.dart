class FeaturedAdEntity {
  final String id;
  final String imageUrl;
  final String title;
  final bool isFeatured;

  FeaturedAdEntity({
    required this.id,
    required this.imageUrl,
    required this.title,
    this.isFeatured = false,
  });
}
