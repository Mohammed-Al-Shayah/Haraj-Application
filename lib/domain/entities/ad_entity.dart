class AdEntity {
  final int id;
  final String imageUrl;
  final String title;
  final String location;
  final double price;
  final int likesCount;
  final int commentsCount;
  final String createdAt;
  final double latitude;
  final double longitude;
  final String? currencySymbol;
  final bool isLiked;
  final int? likeId;

  AdEntity(
  {
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.price,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
    required this.latitude,
    required this.longitude,
    required this.isLiked,
    this.likeId, 
    this.currencySymbol,
  });
}
