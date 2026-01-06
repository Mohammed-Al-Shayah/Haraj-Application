import 'package:get/get.dart';
import 'package:haraj_adan_app/features/authentication/login/controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
