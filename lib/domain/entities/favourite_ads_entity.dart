class FavouriteAdsEntity {
  final int id;
  final String title;
  final String location;
  final String price;
  final String imageUrl;
  final String? currencySymbol;

  FavouriteAdsEntity({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.imageUrl,
    this.currencySymbol,
  });
}
