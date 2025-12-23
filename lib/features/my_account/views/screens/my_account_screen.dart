import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/widgets/main_bar.dart';
import 'package:haraj_adan_app/core/widgets/side_menu.dart';
import 'package:haraj_adan_app/features/my_account/controllers/my_account_controller.dart';
import 'package:haraj_adan_app/features/my_account/views/widgets/my_account_content.dart';
import 'package:haraj_adan_app/features/my_account/views/widgets/my_account_header.dart';
import 'package:get/get.dart';

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyAccountController());
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      appBar: MainBar(
        title: AppStrings.myAccountTitle,
        menu: true,
        scaffoldKey: scaffoldKey,
      ),
      drawer: SideMenu(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Obx(() {
              return MyAccountHeader(
                email: controller.userEmail.value,
                username: controller.userName.value,
              );
            }),
            MyAccountContent(),
          ],
        ),
      ),
    );
  }
}
