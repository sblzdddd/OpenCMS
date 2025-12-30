import 'package:flutter/material.dart';
import '../quick_actions/reorderable_wrap.dart';
import '../quick_actions/action_item/trash_can_item.dart';
import '../../../services/dashboard_layout_storage_service.dart';
import 'widget_size_manager.dart';
import 'widget_tile_builder.dart';

/// Controller to trigger actions on DashboardGrid from parent widgets
class DashboardGridController extends ChangeNotifier {
  void Function(String widgetId, Size size)? _addWidgetHandler;
  void Function()? _resetLayoutHandler;
  List<String> Function()? _getAddableWidgetsHandler;

  /// Request all dashboard widgets to refresh their data
  void refresh() {
    notifyListeners();
  }

  /// Add a widget via the bound grid state
  void addWidget(String widgetId, Size size) {
    _addWidgetHandler?.call(widgetId, size);
  }

  /// Reset the layout to default via the bound grid state
  void resetLayout() {
    if (_resetLayoutHandler != null) {
      _resetLayoutHandler!.call();
      return;
    }
    // Fallback: persist default layout immediately so the grid picks it up on mount
    final DashboardLayoutStorageService storage =
        DashboardLayoutStorageService();
    storage.saveLayout(
      List<MapEntry<String, Size>>.from(WidgetSizeManager.defaultLayout),
    );
  }

  /// Query which widgets are available to add right now
  List<String> getAddableWidgets() {
    final handler = _getAddableWidgetsHandler;
    if (handler != null) {
      return handler();
    }
    // Fallback: compute against current default layout when grid state is not yet bound
    return WidgetSizeManager.getAddableWidgets(
      List<MapEntry<String, Size>>.from(WidgetSizeManager.defaultLayout),
    );
  }
}

class DashboardGrid extends StatefulWidget {
  final VoidCallback? onRefresh;
  final DashboardGridController? controller;
  final bool isReadOnly;

  const DashboardGrid({
    super.key,
    this.onRefresh,
    this.controller,
    this.isReadOnly = false,
  });

  @override
  State<DashboardGrid> createState() => _DashboardGridState();
}

class _DashboardGridState extends State<DashboardGrid> {
  final DashboardLayoutStorageService _storage =
      DashboardLayoutStorageService();
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
    // Bind controller command handlers
    widget.controller?._addWidgetHandler = (id, size) => _addWidget(id, size);
    widget.controller?._resetLayoutHandler = () {
      setState(() {
        _isEditMode = true; // briefly enter edit to show changes
        _widgetOrder = List<MapEntry<String, Size>>.from(
          WidgetSizeManager.defaultLayout,
        );
      });
      _saveLayout();
      // Exit edit mode immediately since add button is persistent now
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _isEditMode = false);
        }
      });
    };
    widget.controller?._getAddableWidgetsHandler = () {
      return WidgetSizeManager.getAddableWidgets(_widgetOrder);
    };
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
    if (widget.controller != null) {
      widget.controller!._addWidgetHandler = null;
      widget.controller!._resetLayoutHandler = null;
      widget.controller!._getAddableWidgetsHandler = null;
    }
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
            _widgetOrder = List<MapEntry<String, Size>>.from(
              WidgetSizeManager.defaultLayout,
            );
          } else {
            // Use the saved layout directly since it now includes sizes
            _widgetOrder = List<MapEntry<String, Size>>.from(saved);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('DashboardGrid: Error loading layout: $e');
      if (mounted) {
        setState(() {
          // On error, try to load the saved layout again, but if that fails, use default
          _widgetOrder = List<MapEntry<String, Size>>.from(
            WidgetSizeManager.defaultLayout,
          );
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

  Widget _buildTile(
    MapEntry<String, Size> entry,
    double baseTileWidth,
    double spacing,
    BuildContext context,
  ) {
    return WidgetTileBuilder.buildTile(
      entry,
      baseTileWidth,
      spacing,
      _isEditMode,
      context,
      // Make widgets non-clickable
      isEditModeParam: _isEditMode,
      // Refresh callback to widgets
      onRefresh: widget.onRefresh,
      refreshTick: _refreshTick,
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
            final int columns =
                ((constraints.maxWidth + spacing) / (minColWidth + spacing))
                    .floor()
                    .clamp(1, maxColumns);
            final double baseTileWidth =
                (constraints.maxWidth - (columns - 1) * spacing) / columns;

            final List<Widget> tiles = _widgetOrder
                .map(
                  (entry) => _buildTile(entry, baseTileWidth, spacing, context),
                )
                .toList();

            if (_isEditMode) {
              // Full-width trash can row
              tiles.add(
                SizedBox(
                  key: const ValueKey('trash_can'),
                  width: constraints.maxWidth,
                  child: TrashCanItem(tileWidth: constraints.maxWidth),
                ),
              );
            }

            return ReorderableWrap(
              spacing: spacing,
              runSpacing: spacing,
              alignment: WrapAlignment.start,
              isEditMode: _isEditMode,
              enableReorder: !widget.isReadOnly,
              wrapId: 'dashboard_grid',
              onReorderStart: () {
                if (widget.isReadOnly) return;
                setState(() {
                  _isEditMode = true;
                });
              },
              onReorderEnd: () {
                if (mounted) {
                  setState(() => _isEditMode = false);
                }
              },
              onReorder: _onReorder,
              onRemove: _onRemove,
              children: tiles,
            );
          },
        ),
      ],
    );
  }
}
