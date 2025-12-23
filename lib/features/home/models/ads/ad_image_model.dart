class AdImageModel {
  final int id;
  final int adId;
  final String image;
  final DateTime? created;
  final DateTime? updated;

  AdImageModel({
    required this.id,
    required this.adId,
    required this.image,
    this.created,
    this.updated,
  });

  factory AdImageModel.fromJson(Map<String, dynamic> json) {
    return AdImageModel(
      id: json['id'] ?? 0,
      adId: json['ad_id'] ?? 0,
      image: json['image'] ?? '',
      created:
          json['created'] != null ? DateTime.tryParse(json['created']) : null,
      updated:
          json['updated'] != null ? DateTime.tryParse(json['updated']) : null,
    );
  }
}
