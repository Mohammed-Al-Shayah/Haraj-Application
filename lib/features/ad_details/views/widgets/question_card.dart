// import 'package:flutter/material.dart';
// import 'package:haraj_adan_app/core/theme/color.dart';
// import '../../../../core/theme/strings.dart';
// import '../../../../core/theme/typography.dart';
// import '../../models/comment_model.dart';

// class QuestionCard extends StatelessWidget {
//   final List<CommentModel> comments;
//   const QuestionCard({super.key, required this.comments});

//   String _formatTime(String raw) {
//     final dt = DateTime.tryParse(raw);
//     if (dt == null) return raw;
//     final diff = DateTime.now().difference(dt);
//     if (diff.inMinutes < 1) return 'Just now';
//     if (diff.inMinutes < 60) return '${diff.inMinutes} ${AppStrings.minutesAgo}';
//     if (diff.inHours < 24) return '${diff.inHours} ${AppStrings.hoursAgo}';
//     return '${diff.inDays} ${AppStrings.daysAgo}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ListView.separated(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: comments.length,
//           separatorBuilder: (_, _) => Divider(color: Colors.grey.shade300),
//           itemBuilder: (context, index) {
//             final c = comments[index];
//             return Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const CircleAvatar(radius: 23.0),
//                   const SizedBox(width: 10.0),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       // Todo cheak this if change when do comments models
//                       children: [
//                         Text(c.user!.name.isEmpty ? c.user!.name : 'Guest',
//                             style: AppTypography.bold16),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             const Icon(
//                               Icons.watch_later_outlined,
//                               size: 14,
//                               color: AppColors.gray500,
//                             ),
//                             const SizedBox(width: 5),
//                             Text(
//                               _formatTime(c.created),
//                               style: AppTypography.normal14.copyWith(
//                                 color: AppColors.gray500,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           c.text,
//                           style: AppTypography.normal12,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import 'package:haraj_adan_app/domain/entities/comment_entity.dart';

class QuestionCard extends StatelessWidget {
  final List<CommentEntity> comments;

  const QuestionCard({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          comments.map((c) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.userName.isEmpty ? 'User' : c.userName,
                    style: AppTypography.bold14,
                  ),
                  const SizedBox(height: 6),
                  Text(c.text, style: AppTypography.normal14),
                ],
              ),
            );
          }).toList(),
    );
  }
}
