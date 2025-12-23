import '../../domain/entities/favourite_ads_entity.dart';

class FavouriteAdsModel extends FavouriteAdsEntity {
  FavouriteAdsModel({
    required super.id,
    required super.title,
    required super.location,
    required super.price,
    required super.imageUrl,
    super.currencySymbol,
  });

  factory FavouriteAdsModel.fromJson(Map<String, dynamic> json) {
    return FavouriteAdsModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'],
      location: json['location'],
      price: json['price'],
      imageUrl: json['image'],
      currencySymbol: json['currencies']?.toString(),
    );
  }
}
