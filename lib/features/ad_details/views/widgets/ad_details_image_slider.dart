import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/features/ad_details/controllers/ad_details_controller.dart';

class AdDetailsImageSliderController extends GetxController {
  final defaultImages = [
    'https://www.thespruce.com/thmb/BpZG-gG2ReQwYpzrQg302pezLr0=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/Stocksy_txp3d216bb1tUq300_Medium_4988078-56c96ac19def4bf8ba430cf5063b6b38.jpg',
    'https://cdn.apartmenttherapy.info/image/upload/f_auto,q_auto:eco,c_fill,g_center,w_730,h_730/at%2Fhouse%20tours%2F2023-House-Tours%2F2023-January%2FLu-Chan%2Fhouse-tours-lu-chan-new-york-037649',
    'https://rentpath-res.cloudinary.com/t_w_webp_xl/t_unpaid/6a4ee973675978ccae2e34b26dbc49ba',
  ];

  late List<String> images;

  final currentIndex = 0.obs;
  final pageController = PageController(viewportFraction: 0.8);

  void initImages(List<String>? providedImages) {
    images = providedImages?.isNotEmpty == true ? providedImages! : defaultImages;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }
}

class AdDetailsImageSlider extends StatelessWidget {
  const AdDetailsImageSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final adDetails = Get.find<AdDetailsController>();
    final sliderController = Get.put(AdDetailsImageSliderController());
    sliderController.initImages(adDetails.ad.value?.images);

    return Obx(() {
      sliderController.initImages(adDetails.ad.value?.images);

      return Padding(
        padding: EdgeInsets.only(
          top: 16,
          left: sliderController.currentIndex.value == 0 ? 16 : 0,
          right:
              sliderController.currentIndex.value == sliderController.images.length - 1
                  ? 16
                  : 0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 277,
              child: Align(
                alignment: Alignment.centerLeft,
                child: PageView.builder(
                  controller: sliderController.pageController,
                  padEnds: false,
                  itemCount: sliderController.images.length,
                  onPageChanged: sliderController.onPageChanged,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 277,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          sliderController.images[index],
                          width: 277,
                          height: 277,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.error)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(sliderController.images.length, (index) {
                final isActive = index == sliderController.currentIndex.value;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 12 : 8,
                  height: isActive ? 12 : 8,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ],
        ),
      );
    });
  }
}
