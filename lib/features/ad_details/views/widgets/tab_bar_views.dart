import 'package:flutter/material.dart';
import 'package:haraj_adan_app/features/ad_details/views/widgets/tab_bar_settings.dart';
import 'package:haraj_adan_app/features/ad_details/views/widgets/tab_bar_views_content.dart';

class TabBarViews extends StatelessWidget {
  const TabBarViews({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: TabBarSettings(),
          ),
          const TabBarViewsContent(),
        ],
      ),
    );
  }
}
