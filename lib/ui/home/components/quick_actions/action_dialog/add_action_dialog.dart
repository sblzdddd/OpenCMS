import 'package:flutter/material.dart';
import '../../../../../data/constants/quick_actions_constants.dart';
import 'base_action_dialog.dart';

/// Dialog for adding new quick actions
class AddActionDialog extends BaseActionDialog {
  final Function(Map<String, dynamic>) onActionSelected;

  const AddActionDialog({
    super.key,
    required super.currentActionIds,
    required this.onActionSelected,
  });

  @override
  State<AddActionDialog> createState() => _AddActionDialogState();
}

class _AddActionDialogState extends BaseActionDialogState<AddActionDialog> {
  @override
  String get dialogTitle => 'Add Quick Action';

  @override
  String get searchHint => 'Search actions...';

  @override
  String get emptyStateMessage => 'All actions are already added!';

  @override
  List<Map<String, dynamic>> getAvailableActions() {
    return QuickActionsConstants.getAvailableActionsToAdd(widget.currentActionIds);
  }

  @override
  void onActionTap(Map<String, dynamic> action) {
    widget.onActionSelected(action);
  }
}
