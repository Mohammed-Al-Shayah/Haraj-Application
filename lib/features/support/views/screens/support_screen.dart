import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/widgets/main_bar.dart';
import 'package:haraj_adan_app/core/widgets/side_menu.dart';
import '../../models/support_model.dart';
import '../../../../core/theme/strings.dart';
import '../widgets/support_item.dart';
import '../widgets/support_search.dart';

class SupportScreen extends StatelessWidget {
  SupportScreen({super.key});

  final List<Support> messages =
      [
        {
          'name': 'Athalia Putri',
          'message': 'Good morning',
          'time': 'Today',
          'image':
              'https://i.pinimg.com/736x/8c/6d/db/8c6ddb5fe6600fcc4b183cb2ee228eb7.jpg',
          'status': 'online',
        },
        {
          'name': 'Raki Devon',
          'message': 'How is it going?',
          'time': '17/6',
          'image': '',
          'status': 'offline',
        },
        {
          'name': 'Liam Smith',
          'message': 'Are you available?',
          'time': 'Yesterday',
          'image':
              'https://i.pinimg.com/736x/0b/97/6f/0b976f0a7aa1aa43870e1812eee5a55d.jpg',
          'status': 'online',
        },
        {
          'name': 'Olivia Johnson',
          'message': 'Let\'s catch up later!',
          'time': '16/6',
          'image':
              'https://i.pinimg.com/736x/8c/6d/db/8c6ddb5fe6600fcc4b183cb2ee228eb7.jpg',
          'status': 'offline',
        },
      ].map((e) => Support.fromMap(e)).toList();

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      appBar: MainBar(
        title: AppStrings.supportTitle,
        menu: true,
        scaffoldKey: scaffoldKey,
      ),
      drawer: SideMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SupportSearch(),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder:
                    (_, index) => SupportItem(support: messages[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
