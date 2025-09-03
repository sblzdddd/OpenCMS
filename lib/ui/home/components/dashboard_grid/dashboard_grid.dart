import 'package:flutter/material.dart';
import '../quick_actions/reorderable_wrap.dart';
import '../quick_actions/action_item/trash_can_item.dart';
import '../quick_actions/action_item/add_action_item.dart';
import '../../../../services/home/dashboard_layout_storage_service.dart';
import 'widget_size_manager.dart';
import 'add_widget_drawer.dart';
import 'widget_tile_builder.dart';

/// Controller to trigger actions on DashboardGrid from parent widgets
class DashboardGridController extends ChangeNotifier {
  /// Request all dashboard widgets to refresh their data
  void refresh() {
    notifyListeners();
  }
}

class DashboardGrid extends StatefulWidget {
  final VoidCallback? onRefresh;
  final DashboardGridController? controller;
  
  const DashboardGrid({super.key, this.onRefresh, this.controller});

  @override
  State<DashboardGrid> createState() => _DashboardGridState();
}

class _DashboardGridState extends State<DashboardGrid> {
  final DashboardLayoutStorageService _storage = DashboardLayoutStorageService();
  bool _isLoading = true;
  bool _isEditMode = false;
  int _refreshTick = 0; // Increments to force child widget subtree rebuild

  // Ordered list of widget IDs with their sizes
  List<MapEntry<String, Size>> _widgetOrder = <MapEntry<String, Size>>[];

  @override
  void initState() {
    super.initState();
    _loadLayout();
    // Attach controller listener if provided
    widget.controller?.addListener(_handleExternalRefresh);
  }

  @override
  void didUpdateWidget(covariant DashboardGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleExternalRefresh);
      widget.controller?.addListener(_handleExternalRefresh);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleExternalRefresh);
    super.dispose();
  }

  void _handleExternalRefresh() {
    refreshAllWidgets();
  }

  Future<void> _loadLayout() async {
    try {
      final saved = await _storage.loadLayout();
      if (mounted) {
        setState(() {
          if (saved == null || saved.isEmpty) {
            // Only use default layout if no saved layout exists
            _widgetOrder = List<MapEntry<String, Size>>.from(WidgetSizeManager.defaultLayout);
          } else {
            // Use the saved layout directly since it now includes sizes
            _widgetOrder = List<MapEntry<String, Size>>.from(saved);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('DashboardGrid: Error loading layout: $e');
      if (mounted) {
        setState(() {
          // On error, try to load the saved layout again, but if that fails, use default
          _widgetOrder = List<MapEntry<String, Size>>.from(WidgetSizeManager.defaultLayout);
          _isLoading = false;
        });
      }
    }
  }

  /// Refresh all widgets in the dashboard
  Future<void> refreshAllWidgets() async {
    // Increment tick to force child subtree rebuilds
    if (mounted) {
      setState(() {
        _refreshTick++;
      });
    }
    // Trigger refresh callback if provided (kept for backward compatibility)
    widget.onRefresh?.call();
    // Don't reload the layout on refresh - this was causing the reset issue
    // await _loadLayout();
  }

  Future<void> _saveLayout() async {
    // Save the complete layout with sizes
    await _storage.saveLayout(_widgetOrder);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final entry = _widgetOrder.removeAt(oldIndex);
      _widgetOrder.insert(newIndex, entry);
    });
    _saveLayout();
  }

  void _onRemove(int index) {
    setState(() {
      if (index >= 0 && index < _widgetOrder.length) {
        _widgetOrder.removeAt(index);
      }
    });
    _saveLayout();
  }

  /// Add a new widget to the grid
  void _addWidget(String widgetId, Size size) {
    setState(() {
      _widgetOrder.add(MapEntry(widgetId, size));
    });
    _saveLayout();
  }

  /// Change widget size
  void _changeWidgetSize(String widgetId, Size newSize) {
    final currentIndex = _widgetOrder.indexWhere((e) => e.key == widgetId);
    if (currentIndex == -1) return;

    setState(() {
      final widgetId = _widgetOrder[currentIndex].key;
      _widgetOrder[currentIndex] = MapEntry(widgetId, newSize);
    });
    _saveLayout();
  }

  /// Exit edit mode
  void _exitEditMode() {
    setState(() {
      _isEditMode = false;
    });
  }

  /// Show the add widget drawer
  void _showAddWidgetDrawer() {
    final addableWidgets = WidgetSizeManager.getAddableWidgets(_widgetOrder);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddWidgetDrawer(
        addableWidgets: addableWidgets,
        onAddWidget: _addWidget,
      ),
    );
  }

  /// Handle widget size change
  void _handleSizeChange(String widgetId) {
    final currentIndex = _widgetOrder.indexWhere((e) => e.key == widgetId);
    if (currentIndex == -1) return;

    final currentSize = _widgetOrder[currentIndex].value;
    WidgetTileBuilder.showSizeChangeDialog(
      context,
      widgetId,
      currentSize,
      (newSize) => _changeWidgetSize(widgetId, newSize),
    );
  }

  Widget _buildTile(MapEntry<String, Size> entry, double baseTileWidth, double spacing) {
    return WidgetTileBuilder.buildTile(
      entry,
      baseTileWidth,
      spacing,
      _isEditMode,
      _handleSizeChange,
      isEditModeParam: _isEditMode, // Pass edit mode to make widgets non-clickable
      onRefresh: widget.onRefresh, // Pass refresh callback to widgets
      refreshTick: _refreshTick, // Key child content by refresh tick
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            const double spacing = 16.0;
            const int maxColumns = 4;
            const double minColWidth = 60.0;
            final int columns = ((constraints.maxWidth + spacing) / (minColWidth + spacing))
                .floor()
                .clamp(1, maxColumns);
            final double baseTileWidth = (constraints.maxWidth - (columns - 1) * spacing) / columns;

            final List<Widget> tiles = _widgetOrder
                .map((entry) => _buildTile(entry, baseTileWidth, spacing))
                .toList();
            
            if (_isEditMode) {
              // Add trash can
              tiles.add(TrashCanItem(tileWidth: baseTileWidth));
              
              // Add add button if there are widgets available to add
              final addableWidgets = WidgetSizeManager.getAddableWidgets(_widgetOrder);
              if (addableWidgets.isNotEmpty) {
                tiles.add(
                  AddActionItem(
                    tileWidth: baseTileWidth,
                    onTap: _showAddWidgetDrawer,
                  ),
                );
              }
            }

            return ReorderableWrap(
              spacing: spacing,
              runSpacing: spacing,
              alignment: WrapAlignment.start,
              isEditMode: _isEditMode,
              wrapId: 'dashboard_grid',
              onReorderStart: () {
                setState(() {
                  _isEditMode = true;
                });
              },
              onReorder: _onReorder,
              onRemove: _onRemove,
              children: tiles,
            );
          },
        ),
        // FABs for edit mode
        if (_isEditMode)
          Positioned(
            right: 16,
            bottom: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _widgetOrder = List<MapEntry<String, Size>>.from(WidgetSizeManager.defaultLayout);
                    });
                    _saveLayout();
                  },
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  tooltip: 'Reset to Default',
                  child: const Icon(Icons.refresh),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: _exitEditMode,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  tooltip: 'Done',
                  child: const Icon(Icons.check),
                ),
              ],
            ),
          ),
      ],
    );
  }
}


