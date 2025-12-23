import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../../core/routes/routes.dart';
import '../../../../../domain/entities/ad_entity.dart';
import 'ad_item.dart';

class AdsResultSection extends StatelessWidget {
  final List<AdEntity> ads;

  const AdsResultSection({super.key, required this.ads});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, left: 20.0, bottom: 20.0),
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
              likesCount: ads[index].likesCount,
              commentsCount: ads[index].commentsCount,
              createdAt: ads[index].createdAt.toString(),
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
