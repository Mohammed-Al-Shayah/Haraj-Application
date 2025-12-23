import '../../domain/entities/not_published_entity.dart';

class NotPublishedModel extends NotPublishedEntity {
  NotPublishedModel({
    required super.id,
    required super.title,
    required super.location,
    required super.price,
    required super.imageUrl,
    super.status,
    super.latitude,
    super.longitude,
  });

  factory NotPublishedModel.fromJson(Map<String, dynamic> json) {
    return NotPublishedModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title'],
      location: json['location'],
      price: json['price'],
      imageUrl: json['image'],
      status: json['status'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
