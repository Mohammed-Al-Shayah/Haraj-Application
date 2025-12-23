import 'package:flutter/material.dart';
import 'package:haraj_adan_app/features/ad_details/views/widgets/description_tab_bar.dart';
import 'package:haraj_adan_app/features/ad_details/views/widgets/ad_details_tab_bar.dart';
import 'package:haraj_adan_app/features/ad_details/views/widgets/location_tab_bar.dart';

class TabBarViewsContent extends StatelessWidget {
  const TabBarViewsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBarView(
      physics: NeverScrollableScrollPhysics(),
      children: [AdDetailsTabBar(), DescriptionTabBar(), LocationTabBar()],
    );
  }
}
