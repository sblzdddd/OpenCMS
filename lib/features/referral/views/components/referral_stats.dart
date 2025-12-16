import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/features/theme/services/theme_services.dart';
import 'package:opencms/features/referral/models/referral_response.dart';

class ReferralStatsWidget extends StatelessWidget {
  final ThemeNotifier themeNotifier;
  final List<ReferralComment> comments;

  const ReferralStatsWidget({
    super.key,
    required this.themeNotifier,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    final int total = comments.length;
    final int commendations = comments.where((c) => c.isCommendation).length;
    final int concerns = comments.where((c) => c.isAreaOfConcern).length;
    final int withReplies = comments.where((c) => c.hasReplies).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: themeNotifier.getBorderRadiusAll(0.75),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comments Overview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ReferralStatCard(
                  themeNotifier: themeNotifier,
                  label: 'Total',
                  value: total.toString(),
                  icon: Symbols.comment_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ReferralStatCard(
                  themeNotifier: themeNotifier,
                  label: 'Commendations',
                  value: commendations.toString(),
                  icon: Symbols.thumb_up_rounded,
                  iconColor: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ReferralStatCard(
                  themeNotifier: themeNotifier,
                  label: 'Concerns',
                  value: concerns.toString(),
                  icon: Symbols.warning_rounded,
                  iconColor: Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ReferralStatCard(
                  themeNotifier: themeNotifier,
                  label: 'Replies',
                  value: withReplies.toString(),
                  icon: Symbols.reply_rounded,
                  iconColor: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReferralStatCard extends StatelessWidget {
  final ThemeNotifier themeNotifier;
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  const ReferralStatCard({
    super.key,
    required this.themeNotifier,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeNotifier.needTransparentBG
            ? (!themeNotifier.isDarkMode
                  ? Theme.of(
                      context,
                    ).colorScheme.surfaceBright.withValues(alpha: 0.5)
                  : Theme.of(
                      context,
                    ).colorScheme.surfaceContainer.withValues(alpha: 0.8))
            : Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: themeNotifier.getBorderRadiusAll(0.5),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: iconColor ?? Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: iconColor ?? Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
