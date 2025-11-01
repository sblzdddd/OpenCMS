import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/services/theme/theme_services.dart';
import 'package:opencms/data/models/referral/referral_response.dart';
import 'package:opencms/ui/referral/widgets/referral_comment_card.dart';

class ReferralCommentsList extends StatelessWidget {
  final ThemeNotifier themeNotifier;
  final List<ReferralComment> comments;

  const ReferralCommentsList({
    super.key,
    required this.themeNotifier,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Symbols.comment_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No comments found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: comments
          .map(
            (comment) => ReferralCommentCard(
              themeNotifier: themeNotifier,
              comment: comment,
            ),
          )
          .toList(),
    );
  }
}
