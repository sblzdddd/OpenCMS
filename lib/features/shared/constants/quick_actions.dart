import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Contains all available quick actions that users can add to their home screen.
/// Each action has a unique ID, title, and icon.

class QuickAction {
  final String id;
  final String title;
  final dynamic icon;
  final bool? isWebLink;

  QuickAction({
    required this.id,
    required this.title,
    required this.icon,
    this.isWebLink = false,
  });
}

class QuickActionsConstants {
  /// Persistent non-deletable "More..." action
  static const String moreActionId = 'more';

  static QuickAction get moreAction => QuickAction(
    title: 'More',
    icon: Symbols.more_horiz_rounded,
    id: moreActionId,
  );
  /// All available quick actions
  static List<QuickAction> get availableActions => [
    QuickAction(
      title: 'WebCMS',
      icon: Symbols.language,
      id: 'webcms',
      isWebLink: true,
    ),
    QuickAction(
      title: 'Timetable',
      icon: Symbols.calendar_view_day_rounded,
      id: 'timetable',
    ),
    QuickAction(
      title: 'Exams',
      icon: Symbols.calendar_clock_rounded,
      id: 'exam',
    ),
    QuickAction(
      title: 'Attendance',
      icon: Symbols.schedule,
      id: 'attendance',
    ),
    QuickAction(
      title: 'Reports',
      icon: Symbols.assignment_rounded,
      id: 'reports',
    ),
    QuickAction(
      title: 'Assessment',
      icon: Symbols.assessment_rounded,
      id: 'assessment',
    ),
    QuickAction(
      title: 'Comments',
      icon: Symbols.comment_rounded,
      id: 'comments',
    ),
    QuickAction(
      title: 'Calendar',
      icon: Symbols.calendar_month_rounded,
      id: 'calendar',
    ),
    QuickAction(
      title: 'Notices',
      icon: Symbols.notifications_rounded,
      id: 'notice',
    ),
    QuickAction(
      title: 'Daily Bulletin',
      icon: Symbols.format_list_bulleted_rounded,
      id: 'daily_bulletin',
    ),
    QuickAction(
      title: 'Events',
      icon: Symbols.event_upcoming_rounded,
      id: 'events',
    ),
    QuickAction(
      title: 'Homeworks',
      icon: Symbols.edit_note_rounded,
      id: 'homeworks',
    ),
    QuickAction(
      title: 'Documents',
      icon: Symbols.description_rounded,
      id: 'documents',
      isWebLink: true,
    ),
    QuickAction(
      title: 'Available Classrooms',
      icon: Symbols.door_open_rounded,
      id: 'available_classrooms',
    ),
    QuickAction(
      title: 'Maintenance',
      icon: Symbols.build_rounded,
      id: 'maintenance',
      isWebLink: true,
    ),
    QuickAction(
      title: 'Leave Requests',
      icon: Symbols.move_item_rounded,
      id: 'leave_requests',
      isWebLink: true,
    ),
    QuickAction(
      title: 'Student Profile',
      icon: Symbols.person_rounded,
      id: 'student_profile',
    ),
    QuickAction(
      title: 'Course Stats',
      icon: Symbols.school_rounded,
      id: 'course_stats',
    ),
    QuickAction(
      title: 'ECA',
      icon: Symbols.padel_rounded,
      id: 'eca',
      isWebLink: true,
    ),
    QuickAction(
      title: 'Mentoring',
      icon: Symbols.psychiatry_rounded,
      id: 'mentoring',
      isWebLink: true,
    ),
    QuickAction(
      title: 'Global Citizenship',
      icon: Symbols.diversity_2_rounded,
      id: 'global_citizenship',
      isWebLink: true,
    ),
    QuickAction(
      title: 'Surveys',
      icon: Symbols.rate_review_rounded,
      id: 'surveys',
      isWebLink: true,
    ),
    QuickAction(
      title: 'Course Selection',
      icon: Symbols.book_rounded,
      id: 'course_selection',
      isWebLink: true,
    ),
    QuickAction(
      title: 'Exam Entry',
      icon: Symbols.assignment_turned_in_rounded,
      id: 'exam_entry',
      isWebLink: true,
    ),
    QuickAction(
      title: 'Insurance',
      icon: Symbols.health_and_safety_rounded,
      id: 'insurance',
      isWebLink: true,
    ),
    QuickAction(
      title: 'E Agreement',
      icon: Symbols.contract_rounded,
      id: 'e_agreement',
      isWebLink: true,
    ),
    QuickAction(
      title: 'Special Consideration',
      icon: Symbols.bookmark_heart_rounded,
      id: 'special_consideration',
      isWebLink: true,
    ),
    QuickAction(
      title: 'ID Card',
      icon: Symbols.id_card_rounded,
      id: 'id_card',
      isWebLink: true,
    ),
    QuickAction(
      title: 'UniApp',
      icon: Symbols.school_rounded,
      id: 'university_application',
      isWebLink: true,
    ),
    QuickAction(
      title: 'Certifications',
      icon: Symbols.license_rounded,
      id: 'certifications',
      isWebLink: true,
    ),
    QuickAction(
      title: 'Settings',
      icon: Symbols.settings_rounded,
      id: 'settings',
    )
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
  static QuickAction? getActionById(String id) {
    if (id == moreAction.id) {
      return moreAction;
    }
    try {
      return availableActions.firstWhere((action) => action.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get available actions that are not currently displayed
  static List<QuickAction> getAvailableActionsToAdd(
    List<String> currentActionIds,
  ) {
    return availableActions
        .where((action) => action.id != moreAction.id)
        .where((action) => !currentActionIds.contains(action.id))
        .toList();
  }

  /// Get actions from IDs list
  static List<QuickAction> getActionsFromIds(List<String> ids) {
    final List<QuickAction> actions = [];
    for (final id in ids) {
      final action = getActionById(id);
      if (action != null) {
        actions.add(action);
      }
    }
    return actions;
  }

  /// Convert actions list to IDs list
  static List<String> getIdsFromActions(List<QuickAction> actions) {
    return actions.map<String>((action) => action.id).toList();
  }
}
