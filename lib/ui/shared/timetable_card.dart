import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/theme/theme_services.dart';
import '../../data/constants/subject_icons.dart';
import 'scaled_ink_well.dart';

class TimetableCard extends StatelessWidget {
  final String subject;
  final String code;
  final String room;
  final String extraInfo;
  final String? timespan;
  final String? periodText;
  final Function()? onTap;
  final Color? backgroundColor;
  final Color? textColor;

  const TimetableCard({
    super.key,
    required this.subject,
    required this.code,
    required this.room,
    required this.extraInfo,
    this.timespan,
    this.periodText,
    this.onTap,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    final theme = Theme.of(context);
    final iconData = SubjectIconConstants.getIconForSubject(
      subjectName: subject,
      code: code,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (timespan != null || periodText != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(width: 2),
              Text(
                timespan ?? '',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                periodText ?? '',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.5,
                  ),
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        if (timespan != null || periodText != null) const SizedBox(height: 8),
        ScaledInkWell(
          onTap: onTap,
          background: (inkWell) => Material(
            color:
                backgroundColor ??
                (themeNotifier.needTransparentBG && !themeNotifier.isDarkMode
                    ? theme.colorScheme.surfaceBright.withValues(alpha: 0.5)
                    : theme.colorScheme.surfaceContainer.withValues(alpha: 0.6)),
            borderRadius: themeNotifier.getBorderRadiusAll(1.5),
            child: inkWell,
          ),
          borderRadius: themeNotifier.getBorderRadiusAll(1.5),
          child: Stack(
            children: [
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer,
                        borderRadius: themeNotifier.getBorderRadiusAll(0.875),
                      ),
                      child: Icon(
                        iconData,
                        size: 40,
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main content row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left column: Subject info
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Subject Name - Large
                                    Text(
                                      subject,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            textColor ??
                                            theme.colorScheme.onSurface,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    // Subject Id
                                    Text(
                                      code,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontSize: 14,
                                            color:
                                                (textColor ??
                                                        theme
                                                            .colorScheme
                                                            .primary)
                                                    .withValues(alpha: 0.7),
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Right column: Room and Teacher
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Room Id - Large
                                  Text(
                                    room,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          textColor ??
                                          (room.isNotEmpty
                                              ? theme.colorScheme.onSurface
                                              : theme.colorScheme.onSurface
                                                    .withValues(alpha: 0.5)),
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                  const SizedBox(height: 4),
                                  // Teacher Name
                                  Text(
                                    extraInfo,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          (textColor ??
                                                  theme.colorScheme.onSurface)
                                              .withValues(alpha: 0.7),
                                    ),
                                    textAlign: TextAlign.end,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
