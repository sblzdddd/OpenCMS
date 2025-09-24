import 'package:flutter/material.dart';
import 'quick_action_tile.dart';
import '../../../../../pages/actions.dart';

class ActionItem extends StatefulWidget {
  final Map<String, dynamic> action;
  final bool isEditMode;
  final VoidCallback? onTap;
  final double? tileWidth;
  final VoidCallback? onDelete;

  const ActionItem({
    super.key,
    required this.action,
    this.isEditMode = false,
    this.onTap,
    this.tileWidth,
    this.onDelete,
  });

  @override
  State<ActionItem> createState() => _ActionItemState();
}

class _ActionItemState extends State<ActionItem> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    if (widget.isEditMode) {
      return _buildDraggableActionItem(context);
    } else {
      return _buildStaticActionItem(context);
    }
  }

  Widget _buildDraggableActionItem(BuildContext context) {
    return KeyedSubtree(
      key: ValueKey(widget.action['id']),
      child: _buildTileWithContextMenu(
        context,
        QuickActionTile(
          width: widget.tileWidth ?? 100,
          // height: 114,
          icon: widget.action['icon'] as IconData,
          title: widget.action['title'] as String,
          onTap: widget.onTap ?? () => _handleActionTap(context),
          showDragIndicator: true,
        ),
      ),
    );
  }

  Widget _buildStaticActionItem(BuildContext context) {
    return _buildTileWithContextMenu(
      context,
      QuickActionTile(
        width: widget.tileWidth ?? 100,
        // height: 114,
        icon: widget.action['icon'] as IconData,
        title: widget.action['title'] as String,
        onTap: widget.onTap ?? () => _handleActionTap(context),
      ),
    );
  }

  Widget _buildTileWithContextMenu(BuildContext context, Widget child) {
    final bool isDeleteDisabled = widget.onDelete == null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapUp: (details) {
        if (isDeleteDisabled) return;
        _showDeleteMenu(context, details.globalPosition);
      },
      onLongPress: () {
        if (isDeleteDisabled) return;
        // Basic long-press fallback for touch; may be pre-empted by drag in some cases
        final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
        final Offset center = overlay.size.center(Offset.zero);
        _showDeleteMenu(context, overlay.localToGlobal(center));
      },
      child: child,
    );
  }

  Future<void> _showDeleteMenu(BuildContext context, Offset globalPosition) async {
    if (widget.onDelete == null) return;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        globalPosition.dx,
        globalPosition.dy,
      ),
      items: const [
        PopupMenuItem<String>(
          value: 'delete',
          child: Text('Delete action'),
        ),
      ],
    );

    if (selected == 'delete') {
      widget.onDelete?.call();
    }
  }

  void _handleActionTap(BuildContext context) {
    // Try to handle via navigation first (for timetable, homework, assessment)
    if (handleActionNavigation(context, widget.action)) {
      return; // Navigation handled, no need to push new page
    }
    
    // Otherwise, push the action page
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final page = await buildActionPage(widget.action);
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => page,
          ),
        );
      }
    });
  }
}
