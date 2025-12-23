import 'package:flutter/material.dart';
import 'package:haraj_adan_app/features/home/views/widgets/ads/recent_item.dart';
import '../../../../../core/theme/strings.dart';
import '../../../controllers/ad_controller.dart';
import 'package:get/get.dart';

class RecentItemsSection extends StatelessWidget {
  const RecentItemsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AdController controller = Get.find<AdController>();

    return Column(
      children: [
        RecentItem(
          text: AppStrings.gajahMadaBillBoard,
          onPress: () {
            controller.filterAds(AppStrings.gajahMadaBillBoard);
          },
        ),
        RecentItem(
          text: AppStrings.gajahMadaBillBoard,
          onPress: () {
            controller.filterAds(AppStrings.gajahMadaBillBoard);
          },
        ),
        RecentItem(
          text: AppStrings.gajahMadaBillBoard,
          onPress: () {
            controller.filterAds(AppStrings.gajahMadaBillBoard);
          },
        ),
        RecentItem(
          text: AppStrings.gajahMadaBillBoard,
          onPress: () {
            controller.filterAds(AppStrings.gajahMadaBillBoard);
          },
        ),
      ],
    );
  }
}
