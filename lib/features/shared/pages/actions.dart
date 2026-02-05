import 'package:flutter/material.dart';
import 'package:opencms/features/shared/constants/quick_actions.dart';

import '../../navigations/views/app_navigation_controller.dart';

/// Returns true if the action is handled by switching the bottom/rail navigation.
/// timetable -> tab 1, homeworks -> tab 2, assessment -> tab 3
bool handleActionNavigation(BuildContext context, QuickAction action) {
  final String id = action.id;
  final Map<String, int> tabIndex = {
    'timetable': 1,
    'exam': 1,
    'homeworks': 2,
    'feedback': 3,
  };
  final int? index = tabIndex[id];
  if (index != null && AppNavigationController.isInitialized) {
    // Update the context for navigation
    AppNavigationController.updateContext(context);
    // If navigating to exam timetable, select the inner tab 2
    if (id == 'exam') {
      AppNavigationController.setPendingTimetableInnerTabIndex(1);
    }
    // Navigate to the tab
    AppNavigationController.goToTab(index);
    return true;
  }
  return false;
}

Future<void> navigateToAction(BuildContext context, QuickAction action) async {
  if (handleActionNavigation(context, action)) {
    return;
  }
  final String routeName = '/${action.id}';
  Navigator.of(context).pushNamed(routeName);
}
