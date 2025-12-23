class AdAttributeModel {
  final int id;
  final int adId;
  final int categoryAttributeId;
  final String? text;
  final String? textEn;
  final double? lat;
  final double? lng;
  final String? address;

  AdAttributeModel({
    required this.id,
    required this.adId,
    required this.categoryAttributeId,
    this.text,
    this.textEn,
    this.lat,
    this.lng,
    this.address,
  });

  factory AdAttributeModel.fromJson(Map<String, dynamic> json) {
    return AdAttributeModel(
      id: json['id'] ?? 0,
      adId: json['ad_id'] ?? 0,
      categoryAttributeId: json['category_attribute_id'] ?? 0,
      text: json['text'],
      textEn: json['text_en'],
      lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.tryParse(json['lng'].toString()) : null,
      address: json['address'],
    );
  }
}
