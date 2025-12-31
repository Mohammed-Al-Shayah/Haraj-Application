import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/features/home/views/widgets/ads/recent_item.dart';
import '../../../controllers/ad_controller.dart';

class RecentItemsSection extends StatelessWidget {
  final AdController controller;
  final TextEditingController searchController;

  const RecentItemsSection({
    super.key,
    required this.controller,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.recentSearches;
      if (items.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        children: items
            .map(
              (query) => RecentItem(
                text: query,
                onPress: () {
                  searchController.text = query;
                  controller.addRecentSearch(query);
                  controller.filterAds(query);
                },
              ),
            )
            .toList(),
      );
    });
  }
}
