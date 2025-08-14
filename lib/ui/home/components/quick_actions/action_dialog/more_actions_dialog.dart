import 'package:flutter/material.dart';
import '../../../../../data/constants/quick_actions_constants.dart';
import '../../../../../pages/actions/actions.dart';
import 'base_action_dialog.dart';

/// Dialog for choosing hidden actions to launch (not to add to quick access)
class MoreActionsDialog extends BaseActionDialog {
  final void Function(Map<String, dynamic>) onActionChosen;

  const MoreActionsDialog({
    super.key,
    required super.currentActionIds,
    required this.onActionChosen,
  });

  @override
  State<MoreActionsDialog> createState() => _MoreActionsDialogState();
}

class _MoreActionsDialogState extends BaseActionDialogState<MoreActionsDialog> {
  @override
  String get dialogTitle => 'More Actions';

  @override
  String get searchHint => 'Search hidden actions...';

  @override
  String get emptyStateMessage => 'No hidden actions left';

  @override
  List<Map<String, dynamic>> getAvailableActions() {
    return QuickActionsConstants.getAvailableActionsToAdd(widget.currentActionIds);
  }

  @override
  void onActionTap(Map<String, dynamic> action) {
    widget.onActionChosen(action);
    if (mounted) {
      Navigator.of(context).pop();
      
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
}


