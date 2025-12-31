import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../../core/routes/routes.dart';
import '../../../../../domain/entities/ad_entity.dart';
import 'ad_item.dart';

class AdsResultSection extends StatelessWidget {
  final List<AdEntity> ads;
  final ScrollController? scrollController;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback? onLoadMore;

  const AdsResultSection({
    super.key,
    required this.ads,
    this.scrollController,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, left: 20.0, bottom: 20.0),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (!hasMore || isLoadingMore) return false;
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 150) {
            onLoadMore?.call();
          }
          return false;
        },
        child: ListView.builder(
          controller: scrollController,
          itemCount: ads.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (isLoadingMore && index == ads.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Center(child: CupertinoActivityIndicator()),
              );
            }

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
      ),
    );
  }
}
