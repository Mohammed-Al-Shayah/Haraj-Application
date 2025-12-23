class AdFeaturedHistoryModel {
  final int id;
  final int adId;
  final bool status;
  final DateTime endDate;
  final DateTime created;
  final DateTime updated;

  AdFeaturedHistoryModel({
    required this.id,
    required this.adId,
    required this.status,
    required this.endDate,
    required this.created,
    required this.updated,
  });

  factory AdFeaturedHistoryModel.fromJson(Map<String, dynamic> json) {
    return AdFeaturedHistoryModel(
      id: json['id'] ?? 0,
      adId: json['ad_id'] ?? 0,
      status: json['status'] ?? false,
      endDate: DateTime.parse(json['end_date']),
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
    );
  }
}
