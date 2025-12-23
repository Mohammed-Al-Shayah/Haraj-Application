class ShoppingAdEntity {
  final int id;
  final String imageUrl;
  final String title;
  final String location;
  final double price;
  final String? currencySymbol;

  ShoppingAdEntity({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.price,
    this.currencySymbol,
  });
}
