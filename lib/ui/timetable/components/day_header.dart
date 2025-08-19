import 'package:flutter/material.dart';

class DayHeader extends StatelessWidget {
  final String title;
  final String dateText;
  final bool isActive;
  final bool isToday;

  const DayHeader({
    super.key,
    required this.title,
    required this.dateText,
    required this.isActive,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextStyle? textStyle = Theme.of(context).textTheme.titleLarge;

    final Color leadingColor = isActive
        ? colorScheme.primary
        : (isToday
            ? colorScheme.primary.withValues(alpha: 0.6)
            : colorScheme.primary.withValues(alpha: 0.3));

    final Color titleColor = isActive
        ? colorScheme.onSurface
        : (isToday
            ? colorScheme.primary
            : colorScheme.onSurfaceVariant);

    final Color dateColor = isActive || isToday
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 20,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: leadingColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: textStyle?.copyWith(
                color: titleColor,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            dateText,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: dateColor,
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}


