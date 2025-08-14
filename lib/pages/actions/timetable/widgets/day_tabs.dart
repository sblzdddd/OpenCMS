import 'package:flutter/material.dart';

class DayTabs extends StatelessWidget {
  final TabController controller;
  final void Function(int) onTap;
  final List<String> labels;
  final int todayIndex;

  const DayTabs({
    super.key,
    required this.controller,
    required this.onTap,
    required this.labels,
    required this.todayIndex,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: TabBar(
        controller: controller,
        onTap: onTap,
        tabs: [
          for (int i = 0; i < labels.length; i++)
            Tab(
              child: Text(
                labels[i],
                style: TextStyle(
                  color: i == todayIndex ? colorScheme.primary : null,
                  fontWeight: i == todayIndex ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}


