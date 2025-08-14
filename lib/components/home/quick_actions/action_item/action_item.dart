import 'package:flutter/material.dart';
import '../../../common/custom_snackbar/snackbar_utils.dart';
import 'quick_action_tile.dart';

class ActionItem extends StatelessWidget {
  final Map<String, dynamic> action;
  final bool isEditMode;
  final VoidCallback? onTap;

  const ActionItem({
    super.key,
    required this.action,
    this.isEditMode = false,
    this.onTap,
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
        width: 100,
        height: 114,
        icon: action['icon'] as IconData,
        title: action['title'] as String,
        onTap: onTap ?? () => _handleActionTap(context, action['title'] as String),
        showDragIndicator: true,
      ),
    );
  }

  Widget _buildStaticActionItem(BuildContext context) {
    return QuickActionTile(
      width: 100,
      height: 114,
      icon: action['icon'] as IconData,
      title: action['title'] as String,
      onTap: onTap ?? () => _handleActionTap(context, action['title'] as String),
    );
  }

  void _handleActionTap(BuildContext context, String action) {
    SnackbarUtils.showWarning(context, '$action feature coming soon!');
  }
}
