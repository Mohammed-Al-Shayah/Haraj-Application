import '../models/on_air_model.dart';

abstract class OnAirRemoteDataSource {
  Future<List<OnAirModel>> fetchAds();
}

class OnAirRemoteDataSourceImpl implements OnAirRemoteDataSource {
  @override
  Future<List<OnAirModel>> fetchAds() async {
    await Future.delayed(Duration(milliseconds: 300));
    return List.generate(
      10,
      (index) => OnAirModel(
        id: index + 1,
        title: "Billboard in Aden",
        location: "Aden, Yemen",
        price: "120,000",
        status: "Published",
        imageUrl:
            'https://i.pinimg.com/736x/d5/81/95/d58195382738b9530aff24923899387b.jpg',
      ),
    );
  }
}
