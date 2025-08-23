import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class HomeworkCard extends StatelessWidget {
  const HomeworkCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Symbols.book_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
              fill: 1,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  'Homeworks',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              'No recent homework',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
