import 'dart:math';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../action_item/quick_action_tile.dart';

/// Base dialog class for action selection dialogs
abstract class BaseActionDialog extends StatefulWidget {
  final List<String> currentActionIds;

  const BaseActionDialog({
    super.key,
    required this.currentActionIds,
  });
}

abstract class BaseActionDialogState<T extends BaseActionDialog> extends State<T> {
  late List<Map<String, dynamic>> availableActions;
  List<Map<String, dynamic>> filteredActions = [];
  String searchQuery = '';

  /// Override to provide dialog-specific title
  String get dialogTitle;

  /// Override to provide dialog-specific search hint
  String get searchHint;

  /// Override to provide dialog-specific empty state message
  String get emptyStateMessage;

  /// Override to provide dialog-specific actions count text
  String get actionsCountText => '${filteredActions.length} actions available';

  /// Override to handle action selection
  void onActionTap(Map<String, dynamic> action);

  /// Override to get available actions for this dialog
  List<Map<String, dynamic>> getAvailableActions();

  @override
  void initState() {
    super.initState();
    availableActions = getAvailableActions();
    filteredActions = List.from(availableActions);
  }

  void _filterActions(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredActions = List.from(availableActions);
      } else {
        filteredActions = availableActions
            .where((action) => action['title']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      insetPadding: const EdgeInsets.all(28),
      child: Container(
        width: min(MediaQuery.of(context).size.width * 0.9, 440),
        height: min(MediaQuery.of(context).size.height * 0.8, 600),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dialogTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Symbols.close_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search bar
            TextField(
              onChanged: _filterActions,
              decoration: InputDecoration(
                hintText: searchHint,
                prefixIcon: const Icon(Symbols.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(height: 16),

            // Available actions count
            Text(
              actionsCountText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),

            // Actions list
            Expanded(
              child: filteredActions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            searchQuery.isEmpty
                                ? Symbols.check_circle_rounded
                                : Symbols.search_off_rounded,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            searchQuery.isEmpty
                                ? emptyStateMessage
                                : 'No actions match your search',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        const double spacing = 16.0;
                        const double minTileWidth = 100.0;
                        final double availableWidth = constraints.maxWidth;
                        final int columns = (((availableWidth + spacing) /
                                    (minTileWidth + spacing))
                                .floor())
                            .clamp(1, 6);
                        final double tileWidth =
                            (availableWidth - (columns - 1) * spacing) / columns;

                        return SingleChildScrollView(
                          child: Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            alignment: WrapAlignment.start,
                            children: filteredActions.map((action) {
                              return QuickActionTile(
                                width: tileWidth,
                                icon: action['icon'] as IconData,
                                title: action['title'] as String,
                                onTap: () {
                                  onActionTap(action);
                                  Navigator.of(context).pop();
                                },
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
