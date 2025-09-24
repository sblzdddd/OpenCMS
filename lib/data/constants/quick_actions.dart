import 'package:material_symbols_icons/material_symbols_icons.dart';


/// Contains all available quick actions that users can add to their home screen.
/// Each action has a unique ID, title, and icon.

class QuickActionsConstants {
  /// Persistent non-deletable "More..." action
  static const Map<String, dynamic> moreAction = {
    'title': 'More...',
    'icon': Symbols.more_horiz_rounded,
    'id': 'more',
  };

  /// All available quick actions
  static const List<Map<String, dynamic>> availableActions = [
    {'title': 'Web CMS', 'icon': Symbols.language, 'id': 'webcms'},
    {'title': 'Timetable', 'icon': Symbols.calendar_view_day_rounded, 'id': 'timetable'},
    {'title': 'Exam Schedule', 'icon': Symbols.calendar_clock_rounded, 'id': 'exam'},
    {'title': 'Attendance', 'icon': Symbols.schedule, 'id': 'attendance'},
    {'title': 'Reports', 'icon': Symbols.assignment_rounded, 'id': 'reports'},
    {'title': 'Assessments', 'icon': Symbols.assessment_rounded, 'id': 'assessment'},
    {'title': 'Comments', 'icon': Symbols.comment_rounded, 'id': 'comments'},
    {'title': 'Calendar', 'icon': Symbols.calendar_month_rounded, 'id': 'calendar'},
    {'title': 'Notices/Events', 'icon': Symbols.notifications_rounded, 'id': 'notice'},
    {'title': 'Homeworks', 'icon': Symbols.edit_note_rounded, 'id': 'homeworks'},
    {'title': 'Documents', 'icon': Symbols.description_rounded, 'id': 'documents'},
    {'title': 'Free Classrooms', 'icon': Symbols.door_open_rounded, 'id': 'available_classrooms'},
    {'title': 'Maintenance', 'icon': Symbols.build_rounded, 'id': 'maintenance'},
    {'title': 'Leave Requests', 'icon': Symbols.move_item_rounded, 'id': 'leave_requests'},
    {'title': 'Profile', 'icon': Symbols.person_rounded, 'id': 'student_profile'},
    {'title': 'Course Stats', 'icon': Symbols.school_rounded, 'id': 'course_stats'},
    {'title': 'ECA', 'icon': Symbols.padel_rounded, 'id': 'eca'},
    {'title': 'Settings', 'icon': Symbols.settings_rounded, 'id': 'settings'},
  ];

  /// Default quick actions (shown when user hasn't customized)
  static const List<String> defaultActionIds = [
    'webcms',
    'timetable',
    'exam',
    'assessment',
    'reports',
    'homeworks',
    'attendance',
    'calendar',
    'notice',
    'settings',
  ];

  /// Get action by ID
  static Map<String, dynamic>? getActionById(String id) {
    if (id == moreAction['id']) {
      return moreAction;
    }
    try {
      return availableActions.firstWhere((action) => action['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// Get available actions that are not currently displayed
  static List<Map<String, dynamic>> getAvailableActionsToAdd(List<String> currentActionIds) {
    return availableActions
        .where((action) => action['id'] != moreAction['id'])
        .where((action) => !currentActionIds.contains(action['id']))
        .toList();
  }

  /// Get actions from IDs list
  static List<Map<String, dynamic>> getActionsFromIds(List<String> ids) {
    final List<Map<String, dynamic>> actions = [];
    for (final id in ids) {
      final action = getActionById(id);
      if (action != null) {
        actions.add(action);
      }
    }
    return actions;
  }

  /// Convert actions list to IDs list
  static List<String> getIdsFromActions(List<Map<String, dynamic>> actions) {
    return actions.map<String>((action) => action['id'] as String).toList();
  }
}
