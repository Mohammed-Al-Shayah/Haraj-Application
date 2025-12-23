import 'package:get/get.dart';
import '../../../domain/entities/on_air_entity.dart';
import '../../../domain/repositories/on_air_repository.dart';

class OnAirController extends GetxController {
  final OnAirRepository repository;

  OnAirController(this.repository);

  var ads = <OnAirEntity>[].obs;
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
