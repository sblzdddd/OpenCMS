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

class _ActionItemState extends State<ActionItem>
    with AutomaticKeepAliveClientMixin {
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
      child: QuickActionTile(
        width: widget.tileWidth ?? 100,
        icon: widget.action['icon'] as IconData,
        title: widget.action['title'] as String,
        onTap: widget.onTap ?? () => _handleActionTap(context),
        showDragIndicator: true,
        skinImageKey: 'actionIcons.${widget.action['id']}',
      ),
    );
  }

  Widget _buildStaticActionItem(BuildContext context) {
    return QuickActionTile(
      width: widget.tileWidth ?? 100,
      icon: widget.action['icon'] as IconData,
      title: widget.action['title'] as String,
      onTap: widget.onTap ?? () => _handleActionTap(context),
      skinImageKey: 'actionIcons.${widget.action['id']}',
    );
  }

  void _handleActionTap(BuildContext context) {
    // Try to handle via navigation first (for timetable, homework, assessment)
    // if (handleActionNavigation(context, widget.action)) {
    //   return; // Navigation handled, no need to push new page
    // }
    // wait for 1 second
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final page = await buildActionPage(widget.action);
      if (mounted && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => page,
          ),
        );
      }
    });
  }
}
