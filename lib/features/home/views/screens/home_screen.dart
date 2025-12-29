import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/data/datasources/home_remote_datasource.dart';
import 'package:haraj_adan_app/data/repositories/home_repository_impl.dart';
import 'package:haraj_adan_app/features/home/views/widgets/shopping_ad_section.dart';
import '../../../../core/theme/color.dart';
import '../../../../core/widgets/category/category_card.dart';
import '../../../../data/datasources/featured_ad_remote_data_source.dart';
import '../../../../data/datasources/shopping_ad_remote_datasource.dart';
import '../../../../data/repositories/featured_ad_repository_impl.dart';
import '../../../../data/repositories/shopping_ad_repository_impl.dart';
import '../../controllers/home_controller.dart';
import '../widgets/featured_ads_section.dart';
import '../widgets/home_bar.dart';
import '../widgets/search_card.dart';
import '../../../../core/widgets/side_menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen._({super.key, required this.controller});

  factory HomeScreen({Key? key}) {
    final repo = HomeRepositoryImpl(
      HomeRemoteDataSourceImpl(ApiClient(client: Dio())),
    );

    final homeController = Get.put(
      HomeController(
        homeRepository: repo,
        featuredAdRepository: FeaturedAdRepositoryImpl(
          FeaturedAdRemoteDataSourceImpl(),
        ),
        shoppingAdRepository: ShoppingAdRepositoryImpl(
          ShoppingAdRemoteDataSourceImpl(ApiClient(client: Dio())),
        ),
      ),
      permanent: true,
    );

    return HomeScreen._(key: key, controller: homeController);
  }

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeBar(),
      drawer: SideMenu(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 150,
                        width: double.infinity,
                        color: AppColors.primary,
                      ),
                      const Positioned(
                        left: 20,
                        right: 20,
                        child: SearchCard(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Column(
            children: [
              CategoryCard(categories: controller.categories),
              FeaturedAdsSection(controller: controller),
              ShoppingAdSection(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}
