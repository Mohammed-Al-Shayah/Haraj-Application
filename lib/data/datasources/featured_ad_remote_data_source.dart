import '../models/featured_ad_model.dart';

abstract class FeaturedAdRemoteDataSource {
  Future<List<FeaturedAdModel>> getFeaturedAds();
}

class FeaturedAdRemoteDataSourceImpl implements FeaturedAdRemoteDataSource {
  @override
  Future<List<FeaturedAdModel>> getFeaturedAds() async {
    await Future.delayed(const Duration(seconds: 1));

    final imageUrls = [
      'https://i.pinimg.com/736x/ee/29/d3/ee29d34a2fa59f383ca3c7433561361a.jpg',
      'https://i.pinimg.com/736x/09/5a/ae/095aae32fe15e0cb9cc230f43c348c7a.jpg',
      'https://i.pinimg.com/736x/e8/36/df/e836dfdbfa4fa1aaa7759cd453fab6bb.jpg',
      'https://i.pinimg.com/736x/c8/f5/2b/c8f52b78d6772d181c2e761308653c35.jpg',
    ];

    final titles = [
      'Luxury Corner Sofa',
      'Velvet 3-Seater',
      'Minimalist Couch',
      'Scandinavian Sofa',
    ];

    return List.generate(50, (index) {
      final i = index % 4;
      return FeaturedAdModel(
        id: '${index + 1}',
        imageUrl: imageUrls[i],
        title: titles[i],
        isFeatured: true,
      );
    });
  }
}
