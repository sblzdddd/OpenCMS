import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// A generic adaptive layout that shows a list on the left and details on the right for wide screens,
/// and navigates to a detail page for mobile screens.
class AdaptiveListDetailLayout<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(T item, bool isSelected) itemBuilder;
  final Widget Function(T item) detailBuilder;
  final T? selectedItem;
  final Function(T item) onItemSelected;
  final Widget? header;
  final Widget? emptyState;
  final double breakpoint;

  const AdaptiveListDetailLayout({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.detailBuilder,
    required this.onItemSelected,
    this.selectedItem,
    this.header,
    this.emptyState,
    this.breakpoint = 800.0,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= breakpoint;

    if (isWideScreen) {
      return _buildWideScreenLayout(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  Widget _buildWideScreenLayout(BuildContext context) {
    return Row(
      children: [
        // Left side - List
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                if (header != null) header!,
                Expanded(
                  child: _buildList(context),
                ),
              ],
            ),
          ),
        ),
        // Right side - Details
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: selectedItem != null
                ? detailBuilder(selectedItem as T)
                : _buildEmptySelectionView(context),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        if (header != null) header!,
        Expanded(
          child: _buildList(context),
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    if (items.isEmpty) {
      return emptyState ?? _buildDefaultEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedItem == item;
        return itemBuilder(item, isSelected);
      },
    );
  }

  Widget _buildDefaultEmptyState(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Symbols.inbox_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No items available',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for updates',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySelectionView(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Symbols.touch_app_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Select an item',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose an item from the list to view details',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
