import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

import '../../../../../theme/services/theme_services.dart';

class AddWidgetSearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const AddWidgetSearchField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search widgets and quick actions...',
          prefixIcon: const Icon(Symbols.search_rounded),
          border: OutlineInputBorder(
            borderRadius: themeNotifier.getBorderRadiusAll(0.75),
            borderSide: BorderSide(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: themeNotifier.getBorderRadiusAll(0.75),
            borderSide: BorderSide(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: themeNotifier.getBorderRadiusAll(0.75),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}
