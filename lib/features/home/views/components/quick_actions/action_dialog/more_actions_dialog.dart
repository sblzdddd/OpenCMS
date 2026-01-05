import 'package:flutter/material.dart';
import '../../../../../shared/constants/quick_actions.dart';
import '../../../../../shared/pages/actions.dart';
import 'base_action_dialog.dart';

/// Dialog for choosing hidden actions to launch (not to add to quick access)
class MoreActionsDialog extends BaseActionDialog {
  final void Function(QuickAction) onActionChosen;

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
  List<QuickAction> getAvailableActions() {
    return QuickActionsConstants.getAvailableActionsToAdd(
      widget.currentActionIds,
    );
  }

  @override
  void onActionTap(QuickAction action) {
    widget.onActionChosen(action);
    if (!mounted) return;

    // First try to handle via global tab navigation. If handled, the controller
    // will pop the dialog and switch tabs safely.
    if (handleActionNavigation(context, action)) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final page = await buildActionPage(action);
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
      }
    });
  }
}
