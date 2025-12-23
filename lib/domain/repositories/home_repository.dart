import 'package:haraj_adan_app/features/home/models/ads/add_model.dart';
import 'package:haraj_adan_app/features/home/models/category.model.dart';

abstract class HomeRepository {
  Future<List<AdModel>> getHomeAds();
  Future<List<AdModel>> getNearbyAds(double lat, double lng);
  Future<List<CategoryModel>> getHomeCategories();
}
