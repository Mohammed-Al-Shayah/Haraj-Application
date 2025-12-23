import 'package:flutter/material.dart';
import 'package:haraj_adan_app/features/chat/views/widgets/chat_bubble.dart';

class SupportBubbleList extends StatelessWidget {
  const SupportBubbleList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: const [
          ChatBubble(
            text: 'Readable content of a page when looking at its layout.',
            isSender: true,
          ),
          ChatBubble(text: 'Content of a page looking', isSender: false),
          ChatBubble(
            text:
                'It is a long established fact that a reader will be distracted',
            isSender: true,
          ),
          ChatBubble(
            text:
                'Lorem Ipsum is simply dummy text of the printing and typesetting industry. scrambled it to make a type specimen book. It has survived.',
            isSender: false,
          ),
        ],
      ),
    );
  }
}
