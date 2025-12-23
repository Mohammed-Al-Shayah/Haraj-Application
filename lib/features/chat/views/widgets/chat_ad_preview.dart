import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/features/home/views/widgets/ads/ad_item.dart';

class ChatAdPreview extends StatelessWidget {
  const ChatAdPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      height: 100,
      child: AdItem(
        imageUrl:
            'https://i.pinimg.com/736x/af/82/e6/af82e69f92fedcde3ea205a6fdfd7764.jpg',
        title: 'Gajah Mada Billboard',
        location: 'Surakarta, Jawa Tengah',
        price: 10.000,
        onTap: () {},
        showDivider: false,
      ),
    );
  }
}
