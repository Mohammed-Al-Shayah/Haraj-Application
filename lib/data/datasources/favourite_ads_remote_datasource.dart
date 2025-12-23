import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favourite_ads_model.dart';

abstract class FavouriteAdsRemoteDataSource {
  Future<List<FavouriteAdsModel>> fetchFavouriteAds();
}

class FavouriteAdsRemoteDataSourceImpl implements FavouriteAdsRemoteDataSource {
  static const String _prefsKey = 'favourite_ads';

  @override
  Future<List<FavouriteAdsModel>> fetchFavouriteAds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded.whereType<Map>().map((item) {
      return FavouriteAdsModel(
        id:
            item['id'] is int
                ? item['id'] as int
                : int.tryParse(item['id']?.toString() ?? '') ?? 0,
        title: item['title']?.toString() ?? '',
        location: item['location']?.toString() ?? '',
        price: item['price']?.toString() ?? '',
        imageUrl: item['image']?.toString() ?? '',
        currencySymbol: item['currencies']?.toString(),
      );
    }).toList();
  }
}
