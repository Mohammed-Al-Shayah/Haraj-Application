class BannerModel {
  final int id;
  final int imageOrder;
  final String image;
  final DateTime created;
  final DateTime updated;

  BannerModel({
    required this.id,
    required this.imageOrder,
    required this.image,
    required this.created,
    required this.updated,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      imageOrder: json['image_order'] ?? 0,
      image: json['image'] ?? '',
      created: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
      updated: DateTime.tryParse(json['updated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "image_order": imageOrder,
    "image": image,
    "created": created.toIso8601String(),
    "updated": updated.toIso8601String(),
  };
}
