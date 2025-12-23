import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../../core/routes/routes.dart';
import '../../../../../domain/entities/ad_entity.dart';
import 'ad_item.dart';

class AdsSection extends StatelessWidget {
  final List<AdEntity> ads;

  const AdsSection({super.key, required this.ads});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView.builder(
        itemCount: ads.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: AdItem(
              imageUrl: ads[index].imageUrl,
              title: ads[index].title,
              location: ads[index].location,
              price: ads[index].price,
              currencySymbol: ads[index].currencySymbol,
              onTap: () => Get.toNamed(
                Routes.adDetailsScreen,
                arguments: {'adId': ads[index].id},
              ),
            ),
          );
        },
      ),
    );
  }
}
