import 'package:flutter/material.dart';
import 'package:opencms/features/shared/constants/quick_actions.dart';
import 'package:opencms/features/shared/pages/actions.dart';

import 'quick_action_tile.dart';

class ActionItem extends StatefulWidget {
  final QuickAction action;
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
      key: ValueKey(widget.action.id),
      child: QuickActionTile(
        width: widget.tileWidth ?? 100,
        icon: widget.action.icon,
        title: widget.action.shortTitle ?? widget.action.title,
        onTap: widget.isEditMode
            ? () => {}
            : widget.onTap ?? () => _handleActionTap(context),
        showDragIndicator: true,
        showExternalIcon: widget.action.isWebLink ?? false,
        skinImageKey: 'actionIcons.${widget.action.id}',
      ),
    );
  }

  Widget _buildStaticActionItem(BuildContext context) {
    return QuickActionTile(
      width: widget.tileWidth ?? 100,
      icon: widget.action.icon,
      title: widget.action.shortTitle ?? widget.action.title,
      onTap: widget.isEditMode
          ? () => {}
          : widget.onTap ?? () => _handleActionTap(context),
      showExternalIcon: widget.action.isWebLink ?? false,
      skinImageKey: 'actionIcons.${widget.action.id}',
    );
  }

  void _handleActionTap(BuildContext context) {
    // Try to handle via navigation first (for timetable, homework, assessment)
    navigateToAction(context, widget.action);
  }
}
