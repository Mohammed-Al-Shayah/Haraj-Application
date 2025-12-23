import '../../domain/entities/shopping_ad_entity.dart';

class ShoppingAdModel {
  final int id;
  final String imageUrl;
  final String title;
  final String location;
  final double price;
  final String? currencySymbol;

  ShoppingAdModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.price,
    this.currencySymbol,
  });

  factory ShoppingAdModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) =>
        v == null ? 0 : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0);

    return ShoppingAdModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      imageUrl: _firstImage(json),
      title: json['title']?.toString() ?? '',
      location: json['address']?.toString() ?? '',
      price: toDouble(json['price']),
      currencySymbol: json['currencies'] is Map
          ? json['currencies']['symbol']?.toString()
          : null,
    );
  }

  static String _firstImage(Map<String, dynamic> json) {
    final images = json['ads_images'];
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      if (first is Map && first['image'] != null) {
        return first['image'].toString();
      }
    }
    return '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'location': location,
      'price': price,
      'currencySymbol': currencySymbol,
    };
  }

  ShoppingAdEntity toEntity() {
    return ShoppingAdEntity(
      id: id,
      imageUrl: imageUrl,
      title: title,
      location: location,
      price: price,
      currencySymbol: currencySymbol,
    );
  }
}
