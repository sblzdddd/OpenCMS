/// Profile section widget for grouping related information
library;

import 'package:flutter/material.dart';

class ListSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final EdgeInsets padding;

  const ListSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.padding = const EdgeInsets.only(left: 4, bottom: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: padding,
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        
        // Section Content
        ...children.map((child) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: child,
        )),
      ],
    );
  }
}
