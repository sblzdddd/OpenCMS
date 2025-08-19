import 'package:flutter/material.dart';
import 'quick_action_tile.dart';
import '../../../../../pages/actions/actions.dart';

class ActionItem extends StatelessWidget {
  final Map<String, dynamic> action;
  final bool isEditMode;
  final VoidCallback? onTap;
  final double? tileWidth;

  const ActionItem({
    super.key,
    required this.action,
    this.isEditMode = false,
    this.onTap,
    this.tileWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (isEditMode) {
      return _buildDraggableActionItem(context);
    } else {
      return _buildStaticActionItem(context);
    }
  }

  Widget _buildDraggableActionItem(BuildContext context) {
    return KeyedSubtree(
      key: ValueKey(action['id']),
      child: QuickActionTile(
        width: tileWidth ?? 120,
        // height: 114,
        icon: action['icon'] as IconData,
        title: action['title'] as String,
        onTap: onTap ?? () => _handleActionTap(context),
        showDragIndicator: true,
      ),
    );
  }

  Widget _buildStaticActionItem(BuildContext context) {
    return QuickActionTile(
      width: tileWidth ?? 120,
      // height: 114,
      icon: action['icon'] as IconData,
      title: action['title'] as String,
      onTap: onTap ?? () => _handleActionTap(context),
    );
  }

  void _handleActionTap(BuildContext context) {
    // Try to handle via navigation first (for timetable, homework, assessment)
    if (handleActionNavigation(context, action)) {
      return; // Navigation handled, no need to push new page
    }
    
    // Otherwise, push the action page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => buildActionPage(action),
      ),
    );
  }
}
