import 'package:flutter/material.dart';
import '../../components/banner_card.dart';
import '../../components/homework_card.dart';
import '../../components/latest_assessment_card.dart';
import '../../components/notice_card.dart';
import '../quick_actions/reorderable_wrap.dart';
import '../quick_actions/action_item/trash_can_item.dart';
import '../../../../services/home/dashboard_layout_storage_service.dart';

class DashboardGrid extends StatefulWidget {
  const DashboardGrid({super.key});

  @override
  State<DashboardGrid> createState() => _DashboardGridState();
}

class _DashboardGridState extends State<DashboardGrid> {
  final DashboardLayoutStorageService _storage = DashboardLayoutStorageService();
  bool _isLoading = true;
  bool _isReordering = false;

  // Ordered list of widget IDs
  List<String> _widgetOrder = <String>[];

  // Default layout
  static const List<String> _defaultLayout = <String>[
    'banner',
    'notices',
    'homework',
    'assessments',
  ];

  // Span definitions in grid units (max 4 columns)
  static const Map<String, Size> _spans = <String, Size>{
    'notices': Size(2, 1),
    'homework': Size(2, 1),
    'assessments': Size(4, 1),
    'banner': Size(4, 2),
  };

  @override
  void initState() {
    super.initState();
    _loadLayout();
  }

  Future<void> _loadLayout() async {
    try {
      final saved = await _storage.loadLayout();
      if (mounted) {
        setState(() {
          _widgetOrder = (saved == null || saved.isEmpty)
              ? List<String>.from(_defaultLayout)
              : List<String>.from(saved);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _widgetOrder = List<String>.from(_defaultLayout);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveLayout() async {
    await _storage.saveLayout(_widgetOrder);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final id = _widgetOrder.removeAt(oldIndex);
      _widgetOrder.insert(newIndex, id);
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

  Widget _buildTile(String id, double baseTileWidth, double spacing) {
    final Size span = _spans[id] ?? const Size(2, 1);
    final int spanX = span.width.round();
    final int spanY = span.height.round();
    final double width = baseTileWidth * spanX + spacing * (spanX - 1);
    final double unitHeight = 100;
    final double height = unitHeight * spanY + spacing * (spanY - 1);

    Widget child;
    switch (id) {
      case 'notices':
        child = const NoticeCard();
        break;
      case 'homework':
        child = const HomeworkCard();
        break;
      case 'assessments':
        child = const LatestAssessment();
        break;
      case 'banner':
        child = const BannerCard();
        break;
      default:
        child = Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(id),
        );
    }

    return SizedBox(
      key: ValueKey('tile_$id'),
      width: width,
      height: height,
      child: child,
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

    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 16.0;
        // Determine how many columns we can fit up to max 4.
        const int maxColumns = 4;
        const double minColWidth = 60.0;
        final int columns = ((constraints.maxWidth + spacing) / (minColWidth + spacing))
            .floor()
            .clamp(1, maxColumns);
        final double baseTileWidth = (constraints.maxWidth - (columns - 1) * spacing) / columns;

        final List<Widget> tiles = _widgetOrder
            .map((id) => _buildTile(id, baseTileWidth, spacing))
            .toList();
        if (_isReordering) {
          tiles.add(TrashCanItem(tileWidth: baseTileWidth));
        }

        return ReorderableWrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.start,
          isEditMode: true,
          onReorderStart: () {
            setState(() {
              _isReordering = true;
            });
          },
          onReorderEnd: () {
            setState(() {
              _isReordering = false;
            });
          },
          onReorder: _onReorder,
          onRemove: _onRemove,
          children: tiles,
        );
      },
    );
  }
}


