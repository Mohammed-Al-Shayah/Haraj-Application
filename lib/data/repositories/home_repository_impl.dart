import 'package:haraj_adan_app/data/datasources/home_remote_datasource.dart';
import 'package:haraj_adan_app/domain/repositories/home_repository.dart';
import 'package:haraj_adan_app/data/models/ad_model.dart' as data_ad;
import 'package:haraj_adan_app/data/models/category_model.dart' as data_cat;
import 'package:haraj_adan_app/features/home/models/ads/add_model.dart';
import 'package:haraj_adan_app/features/home/models/ads/ad_image_model.dart';
import 'package:haraj_adan_app/features/home/models/category.model.dart'
    as ui_category;

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remote;

  HomeRepositoryImpl(this.remote);

  @override
  Future<List<AdModel>> getHomeAds() {
    return remote.getHomeAds().then(_mapAds);
  }

  @override
  Future<List<AdModel>> getNearbyAds(double lat, double lng) {
    return remote.getNearbyAds(lat: lat, lng: lng).then(_mapAds);
  }

  @override
  Future<List<ui_category.CategoryModel>> getHomeCategories() async {
    final list = await remote.getHomeCategories();
    return list.map(_mapCategory).toList();
  }

  List<AdModel> _mapAds(List<data_ad.AdModel> list) {
    return list
        .map(
          (e) => AdModel(
            id: e.id,
            userId: 0,
            title: e.title,
            titleEn: e.title,
            price: e.price.toString(),
            address: e.location,
            latitude: e.latitude,
            longitude: e.longitude,
            distance: 1,
            currencySymbol: e.currencySymbol,
            created: null,
            updated: null,
            featuredHistory: const [],
            images: [
              AdImageModel(
                id: 0,
                adId: e.id,
                image: e.imageUrl,
                created: null,
                updated: null,
              ),
            ],
            attributes: const [],
          ),
        )
        .toList();
  }

  ui_category.CategoryModel _mapCategory(data_cat.CategoryModel e) {
    return ui_category.CategoryModel(
      id: e.id,
      name: e.name,
      nameEn: e.nameEn.isNotEmpty ? e.nameEn : e.name,
      image: e.iconPath,
      adsCount: e.adsCount,
      children: e.subCategories
          .map(
            (sub) => ui_category.CategoryModel(
              id: sub.id,
              name: sub.title,
              nameEn: sub.title,
              image: '',
              adsCount: sub.adsCount,
              children: const [],
            ),
          )
          .toList(),
    );
  }
}
