import 'package:haraj_adan_app/domain/entities/ad_entity.dart';

class FilteredAdsResult {
  final List<AdEntity> ads;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const FilteredAdsResult({
    required this.ads,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });
}
