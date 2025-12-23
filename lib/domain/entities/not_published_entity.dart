class NotPublishedEntity {
  final int id;
  final String title;
  final String location;
  final String price;
  final String imageUrl;
  final String? status;
  final double? latitude;
  final double? longitude;

  NotPublishedEntity({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.imageUrl,
    this.status,
    this.latitude,
    this.longitude,
  });
}
