import 'package:flutter/material.dart';

/// Global navigation controller for handling tab navigation from anywhere in the app
class AppNavigationController {
  static ValueNotifier<int>? _selectedIndexNotifier;
  static BuildContext? _currentContext;
  static int? _pendingTimetableInnerTabIndex;
 
 	static void reset() {
 		_selectedIndexNotifier = null;
 		_currentContext = null;
 		_pendingTimetableInnerTabIndex = null;
 	}
  
  static void initialize(ValueNotifier<int> selectedIndexNotifier) {
    _selectedIndexNotifier = selectedIndexNotifier;
  }
  
  static void updateContext(BuildContext context) {
    _currentContext = context;
  }
  
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
  
  static int get currentTabIndex => _selectedIndexNotifier?.value ?? 0;
  
  static bool get isInitialized => _selectedIndexNotifier != null;

  static void setPendingTimetableInnerTabIndex(int index) {
    _pendingTimetableInnerTabIndex = index;
  }

  static int? takePendingTimetableInnerTabIndex() {
    final value = _pendingTimetableInnerTabIndex;
    _pendingTimetableInnerTabIndex = null;
    return value;
  }
}
