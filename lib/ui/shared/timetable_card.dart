import 'package:flutter/material.dart';
import 'package:opencms/data/constants/constants.dart';

class TimetableCard extends StatelessWidget {
  final String subject;
  final String code;
  final String room;
  final String extraInfo;
  final String timespan;
  final String periodText;
  final Function()? onTap;
  final Color? backgroundColor;
  final Color? textColor;

  const TimetableCard({
    super.key, 
    required this.subject,
    required this.code,
    required this.room,
    required this.extraInfo,
    required this.timespan,
    required this.periodText,
    this.onTap,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconData = SubjectIconConstants.getIconForSubject(
      subjectName: subject,
      code: code,
    );
    final baseTextColor = textColor ?? theme.colorScheme.onSurface;
    final backdropIconColor = baseTextColor.withValues(alpha: 0.06);

    return Column(
      children: [
        // Header row: [Start period name] [stretch space] [time span]
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                timespan,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              periodText,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          color: backgroundColor ?? theme.colorScheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                    color: textColor ?? theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                // Subject Id
                                Text(
                                  code,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: (textColor ?? theme.colorScheme.onSurface).withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Right column: Room and Teacher
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Room Id - Large
                                Text(
                                  room,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: textColor ?? (room.isNotEmpty
                                        ? theme.colorScheme.secondary
                                        : theme.colorScheme.onSurface.withValues(
                                            alpha: 0.5,
                                          )),
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                                const SizedBox(height: 4),
                                // Teacher Name
                                Text(
                                  extraInfo,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: (textColor ?? theme.colorScheme.onSurface).withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                  textAlign: TextAlign.end,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Decorative icon backdrop
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: true,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8, bottom: 8),
                        child: Icon(
                          iconData,
                          size: 96,
                          color: backdropIconColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
