import '../models/not_published_model.dart';

abstract class NotPublishedRemoteDataSource {
  Future<List<NotPublishedModel>> fetchAds();
}

class NotPublishedRemoteDataSourceImpl implements NotPublishedRemoteDataSource {
  @override
  Future<List<NotPublishedModel>> fetchAds() async {
    await Future.delayed(Duration(milliseconds: 300));
    return List.generate(
      10,
      (index) => NotPublishedModel(
        id: index + 1,
        title: "Billboard in Yemen",
        location: "Yemen",
        price: "90,000",
        status: "Not Published",
        imageUrl:
            'https://i.pinimg.com/736x/d5/81/95/d58195382738b9530aff24923899387b.jpg',
      ),
    );
  }
}
