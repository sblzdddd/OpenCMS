import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

import '../../../../../theme/services/theme_services.dart';

class AddWidgetDrawerHeader extends StatelessWidget {
  const AddWidgetDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Column(
      children: [
        // Handle bar
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            borderRadius: themeNotifier.getBorderRadiusAll(0.125),
          ),
        ),
        // Title
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Add Items',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Symbols.close_rounded),
                style: IconButton.styleFrom(
                  backgroundColor:
                      Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
