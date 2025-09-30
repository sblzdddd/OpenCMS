import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/services/theme/theme_services.dart';
import 'package:opencms/ui/shared/widgets/skin_icon_widget.dart';
import 'package:opencms/data/constants/subject_icons.dart';
import 'package:opencms/data/models/referral/referral_response.dart';

class ReferralCommentCard extends StatelessWidget {
  final ThemeNotifier themeNotifier;
  final ReferralComment comment;

  const ReferralCommentCard({
    super.key,
    required this.themeNotifier,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      color: themeNotifier.needTransparentBG
          ? (!themeNotifier.isDarkMode
              ? Theme.of(context).colorScheme.surfaceBright.withValues(alpha: 0.5)
              : Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.8))
          : Theme.of(context).colorScheme.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: themeNotifier.getBorderRadiusAll(1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CommentHeader(themeNotifier: themeNotifier, comment: comment),
            const SizedBox(height: 12),
            _CommentContent(themeNotifier: themeNotifier, comment: comment),
            if (comment.hasReplies) ...[
              const SizedBox(height: 12),
              _RepliesList(themeNotifier: themeNotifier, replies: comment.replies),
            ],
          ],
        ),
      ),
    );
  }
}

class _CommentHeader extends StatelessWidget {
  final ThemeNotifier themeNotifier;
  final ReferralComment comment;

  const _CommentHeader({
    required this.themeNotifier,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.transparent,
          child: SkinIcon(
            imageKey:
                'subjectIcons.${SubjectIconConstants.getCategoryForSubject(subjectName: comment.subject ?? '', code: comment.subject ?? '')}',
            fallbackIcon: Symbols.person_rounded,
            fallbackIconColor: Theme.of(context).colorScheme.primary,
            fallbackIconBackgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            size: 40,
            iconSize: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.teacherName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (comment.subject != null) ...[
                const SizedBox(height: 2),
                Text(
                  comment.subject!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              comment.formattedDate,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            _KindChips(themeNotifier: themeNotifier, comment: comment),
          ],
        ),
      ],
    );
  }
}

class _KindChips extends StatelessWidget {
  final ThemeNotifier themeNotifier;
  final ReferralComment comment;

  const _KindChips({
    required this.themeNotifier,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    if (comment.isCommendation) {
      chipColor = Colors.green;
    } else if (comment.isAreaOfConcern) {
      chipColor = Colors.orange;
    } else {
      chipColor = Colors.blue;
    }

    final List<String> kinds = comment.kindName.split(',');
    if (kinds.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4.0,
      runSpacing: 2.0,
      children: kinds.map((kind) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: chipColor.withValues(alpha: 0.1),
            borderRadius: themeNotifier.getBorderRadiusAll(0.75),
            border: Border.all(color: chipColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            kind,
            style: TextStyle(
              fontSize: 10,
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CommentContent extends StatelessWidget {
  final ThemeNotifier themeNotifier;
  final ReferralComment comment;

  const _CommentContent({
    required this.themeNotifier,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: themeNotifier.getBorderRadiusAll(0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            comment.comment,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          if (comment.commentTranslation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: themeNotifier.needTransparentBG
                    ? (!themeNotifier.isDarkMode
                        ? Theme.of(context).colorScheme.surfaceBright.withValues(alpha: 0.5)
                        : Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.8))
                    : Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: themeNotifier.getBorderRadiusAll(0.375),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                comment.commentTranslation,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RepliesList extends StatelessWidget {
  final ThemeNotifier themeNotifier;
  final List<ReferralReply> replies;

  const _RepliesList({
    required this.themeNotifier,
    required this.replies,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: replies.map((reply) => _ReplyCard(themeNotifier: themeNotifier, reply: reply)).toList(),
    );
  }
}

class _ReplyCard extends StatelessWidget {
  final ThemeNotifier themeNotifier;
  final ReferralReply reply;

  const _ReplyCard({
    required this.themeNotifier,
    required this.reply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeNotifier.needTransparentBG
            ? (!themeNotifier.isDarkMode
                ? Theme.of(context).colorScheme.surfaceBright.withValues(alpha: 0.5)
                : Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.8))
            : Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: themeNotifier.getBorderRadiusAll(0.5),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                child: Text(
                  'FT',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  reply.teacherName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                reply.formattedDate,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reply.comment,
            style: const TextStyle(fontSize: 13, height: 1.3),
          ),
          if (reply.commentTranslation.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              reply.commentTranslation,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
