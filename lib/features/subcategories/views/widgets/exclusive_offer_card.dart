import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/color.dart';

class ExclusiveOfferWidget extends StatelessWidget {
  final String imageUrl;
  // final String title;
  // final String subtitle;
  // final VoidCallback? onPressed;

  const ExclusiveOfferWidget({
    super.key,
    required this.imageUrl,
    // required this.title,
    // required this.subtitle,
    // this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      // child: Stack(
      //   children: [
      //     // تظليل خفيف لتحسين القراءة
      //     Container(
      //       decoration: BoxDecoration(
      //         borderRadius: BorderRadius.circular(12),
      //         color: Colors.black.withOpacity(0.3),
      //       ),
      //     ),
      //
      //     Padding(
      //       padding: const EdgeInsets.all(16.0),
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         mainAxisAlignment: MainAxisAlignment.end,
      //         children: [
      //           Text(
      //             title,
      //             style: const TextStyle(
      //               color: Colors.white,
      //               fontSize: 20,
      //               fontWeight: FontWeight.bold,
      //             ),
      //           ),
      //           const SizedBox(height: 4),
      //           Text(
      //             subtitle,
      //             style: const TextStyle(
      //               color: Colors.white70,
      //               fontSize: 14,
      //             ),
      //           ),
      //           const SizedBox(height: 12),
      //           ElevatedButton(
      //             onPressed: onPressed,
      //             style: ElevatedButton.styleFrom(
      //               backgroundColor: Colors.orangeAccent,
      //               shape: RoundedRectangleBorder(
      //                 borderRadius: BorderRadius.circular(8),
      //               ),
      //             ),
      //             child: const Text(
      //               'Buy Now',
      //               style: TextStyle(color: Colors.white),
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}

class ExclusiveOfferSlider extends StatefulWidget {
  final List<Map<String, String>> offers;

  const ExclusiveOfferSlider({super.key, required this.offers});

  @override
  State<ExclusiveOfferSlider> createState() => _ExclusiveOfferSliderState();
}

class _ExclusiveOfferSliderState extends State<ExclusiveOfferSlider> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.offers.length,
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            itemBuilder: (context, index) {
              final offer = widget.offers[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ExclusiveOfferWidget(
                  imageUrl: offer['imageUrl'] ?? '',
                  // title: offer['title'] ?? '',
                  // subtitle: offer['subtitle'] ?? '',
                  // onPressed: () {
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     SnackBar(content: Text("Clicked: ${offer['title']}")),
                  //   );
                  // },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.offers.length, (index) {
            final isActive = index == currentIndex;
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
    );
  }
}
