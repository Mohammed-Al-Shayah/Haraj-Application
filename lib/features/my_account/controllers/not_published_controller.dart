import 'package:get/get.dart';
import '../../../domain/entities/not_published_entity.dart';
import '../../../domain/repositories/not_published_repository.dart';

class NotPublishedController extends GetxController {
  final NotPublishedRepository repository;

  NotPublishedController(this.repository);

  var ads = <NotPublishedEntity>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadAds();
  }

  void loadAds() async {
    isLoading.value = true;
    ads.value = await repository.getAds();
    isLoading.value = false;
  }
}
