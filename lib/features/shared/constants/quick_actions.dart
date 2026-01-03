import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Contains all available quick actions that users can add to their home screen.
/// Each action has a unique ID, title, and icon.

class QuickActionsConstants {
  /// Persistent non-deletable "More..." action
  static const String moreActionId = 'more';

  static Map<String, dynamic> get moreAction => {
    'title': 'More',
    'icon': Symbols.more_horiz_rounded,
    'id': moreActionId,
  };

  /// All available quick actions
  static List<Map<String, dynamic>> get availableActions => [
    {
      'title': 'WebCMS',
      'icon': Symbols.language,
      'id': 'webcms',
    },
    {
      'title': 'Timetable',
      'icon': Symbols.calendar_view_day_rounded,
      'id': 'timetable',
    },
    {
      'title': 'Exams',
      'icon': Symbols.calendar_clock_rounded,
      'id': 'exam',
    },
    {
      'title': 'Attendance',
      'icon': Symbols.schedule,
      'id': 'attendance',
    },
    {
      'title': 'Reports',
      'icon': Symbols.assignment_rounded,
      'id': 'reports',
    },
    {
      'title': 'Assessment',
      'icon': Symbols.assessment_rounded,
      'id': 'assessment',
    },
    {
      'title': 'Comments',
      'icon': Symbols.comment_rounded,
      'id': 'comments',
    },
    {
      'title': 'Calendar',
      'icon': Symbols.calendar_month_rounded,
      'id': 'calendar',
    },
    {
      'title': 'Notices',
      'icon': Symbols.notifications_rounded,
      'id': 'notice',
    },
    {
      'title': 'Daily Bulletin',
      'icon': Symbols.format_list_bulleted_rounded,
      'id': 'daily_bulletin',
    },
    {
      'title': 'Events',
      'icon': Symbols.event_upcoming_rounded,
      'id': 'events',
    },
    {
      'title': 'Homeworks',
      'icon': Symbols.edit_note_rounded,
      'id': 'homeworks',
    },
    {
      'title': 'Documents',
      'icon': Symbols.description_rounded,
      'id': 'documents',
    },
    {
      'title': 'Available Classrooms',
      'icon': Symbols.door_open_rounded,
      'id': 'available_classrooms',
    },
    {
      'title': 'Maintenance',
      'icon': Symbols.build_rounded,
      'id': 'maintenance',
    },
    {
      'title': 'Leave Requests',
      'icon': Symbols.move_item_rounded,
      'id': 'leave_requests',
    },
    {
      'title': 'Student Profile',
      'icon': Symbols.person_rounded,
      'id': 'student_profile',
    },
    {
      'title': 'Course Stats',
      'icon': Symbols.school_rounded,
      'id': 'course_stats',
    },
    {
      'title': 'ECA',
      'icon': Symbols.padel_rounded,
      'id': 'eca',
    },
    {
      'title': 'Mentoring',
      'icon': Symbols.psychiatry_rounded,
      'id': 'mentoring',
    },
    {
      'title': 'Global Citizenship',
      'icon': Symbols.diversity_2_rounded,
      'id': 'global_citizenship',
    },
    {
      'title': 'Surveys',
      'icon': Symbols.rate_review_rounded,
      'id': 'surveys',
    },
    {
      'title': 'Course Selection',
      'icon': Symbols.book_rounded,
      'id': 'course_selection',
    },
    {
      'title': 'Exam Entry',
      'icon': Symbols.assignment_turned_in_rounded,
      'id': 'exam_entry',
    },
    {
      'title': 'Insurance',
      'icon': Symbols.health_and_safety_rounded,
      'id': 'insurance',
    },
    {
      'title': 'E Agreement',
      'icon': Symbols.contract_rounded,
      'id': 'e_agreement',
    },
    {
      'title': 'Special Consideration',
      'icon': Symbols.bookmark_heart_rounded,
      'id': 'special_consideration',
    },
    {
      'title': 'ID Card',
      'icon': Symbols.id_card_rounded,
      'id': 'id_card',
    },
    {
      'title': 'UniApp',
      'icon': Symbols.school_rounded,
      'id': 'university_application',
    },
    {
      'title': 'Certifications',
      'icon': Symbols.license_rounded,
      'id': 'certifications',
    },
    {
      'title': 'Settings',
      'icon': Symbols.settings_rounded,
      'id': 'settings',
    }
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
  static List<Map<String, dynamic>> getAvailableActionsToAdd(
    List<String> currentActionIds,
  ) {
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
