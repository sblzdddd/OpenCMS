import 'package:flutter/material.dart';

/// Global navigation controller for handling tab navigation from anywhere in the app
class AppNavigationController {
  static ValueNotifier<int>? _selectedIndexNotifier;
  static BuildContext? _currentContext;
  static int? _pendingTimetableInnerTabIndex;
 
 	/// Reset the controller so stale references are cleared (e.g., on logout)
 	static void reset() {
 		_selectedIndexNotifier = null;
 		_currentContext = null;
 		_pendingTimetableInnerTabIndex = null;
 	}
  
  /// Initialize the navigation controller with the selected index notifier
  static void initialize(ValueNotifier<int> selectedIndexNotifier) {
    _selectedIndexNotifier = selectedIndexNotifier;
  }
  
  /// Update the current context (should be called from widgets that want to handle navigation)
  static void updateContext(BuildContext context) {
    _currentContext = context;
  }
  
  /// Navigate to a specific tab
  /// Tab indices: 0 = Home, 1 = Timetable, 2 = Homework, 3 = Feedback
  static void goToTab(int index) {
    if (_selectedIndexNotifier != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Update the selected index after the current frame to avoid setState during build
        // Guard against using a potentially disposed notifier by ensuring we still hold it
        final notifier = _selectedIndexNotifier;
        if (notifier == null) return;
        notifier.value = index;

        // Navigate to home if not already there (all tabs are part of the home page)
        if (_currentContext != null) {
          // Check if we're on a different route and need to pop back to home
          final navigator = Navigator.of(_currentContext!);
          if (navigator.canPop()) {
            navigator.popUntil((route) => route.isFirst);
          }
        }
      });
    }
  }
  
  /// Get the current tab index
  static int get currentTabIndex => _selectedIndexNotifier?.value ?? 0;
  
  /// Check if navigation controller is initialized
  static bool get isInitialized => _selectedIndexNotifier != null;

  /// Set the inner tab for the Timetable page to be applied on next build
  static void setPendingTimetableInnerTabIndex(int index) {
    _pendingTimetableInnerTabIndex = index;
  }

  /// Consume and clear the pending inner tab index for the Timetable page
  static int? takePendingTimetableInnerTabIndex() {
    final value = _pendingTimetableInnerTabIndex;
    _pendingTimetableInnerTabIndex = null;
    return value;
  }
}
