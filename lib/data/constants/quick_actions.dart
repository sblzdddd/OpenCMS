import 'package:easy_localization/easy_localization.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Contains all available quick actions that users can add to their home screen.
/// Each action has a unique ID, title, and icon.

class QuickActionsConstants {
  /// Persistent non-deletable "More..." action
  static const String moreActionId = 'more';

  static Map<String, dynamic> get moreAction => {
    'title': 'quickActions.more'.tr(),
    'icon': Symbols.more_horiz_rounded,
    'id': moreActionId,
  };

  /// All available quick actions
  static List<Map<String, dynamic>> get availableActions => [
    {
      'title': 'quickActions.webcms'.tr(),
      'icon': Symbols.language,
      'id': 'webcms',
    },
    {
      'title': 'quickActions.timetable'.tr(),
      'icon': Symbols.calendar_view_day_rounded,
      'id': 'timetable',
    },
    {
      'title': 'quickActions.exam'.tr(),
      'icon': Symbols.calendar_clock_rounded,
      'id': 'exam',
    },
    {
      'title': 'quickActions.attendance'.tr(),
      'icon': Symbols.schedule,
      'id': 'attendance',
    },
    {
      'title': 'quickActions.reports'.tr(),
      'icon': Symbols.assignment_rounded,
      'id': 'reports',
    },
    {
      'title': 'quickActions.assessment'.tr(),
      'icon': Symbols.assessment_rounded,
      'id': 'assessment',
    },
    {
      'title': 'quickActions.comments'.tr(),
      'icon': Symbols.comment_rounded,
      'id': 'comments',
    },
    {
      'title': 'quickActions.calendar'.tr(),
      'icon': Symbols.calendar_month_rounded,
      'id': 'calendar',
    },
    {
      'title': 'quickActions.notice'.tr(),
      'icon': Symbols.notifications_rounded,
      'id': 'notice',
    },
    {
      'title': 'quickActions.daily_bulletin'.tr(),
      'icon': Symbols.format_list_bulleted_rounded,
      'id': 'daily_bulletin',
    },
    {
      'title': 'quickActions.events'.tr(),
      'icon': Symbols.event_upcoming_rounded,
      'id': 'events',
    },
    {
      'title': 'quickActions.homeworks'.tr(),
      'icon': Symbols.edit_note_rounded,
      'id': 'homeworks',
    },
    {
      'title': 'quickActions.documents'.tr(),
      'icon': Symbols.description_rounded,
      'id': 'documents',
    },
    {
      'title': 'quickActions.available_classrooms'.tr(),
      'icon': Symbols.door_open_rounded,
      'id': 'available_classrooms',
    },
    {
      'title': 'quickActions.maintenance'.tr(),
      'icon': Symbols.build_rounded,
      'id': 'maintenance',
    },
    {
      'title': 'quickActions.leave_requests'.tr(),
      'icon': Symbols.move_item_rounded,
      'id': 'leave_requests',
    },
    {
      'title': 'quickActions.student_profile'.tr(),
      'icon': Symbols.person_rounded,
      'id': 'student_profile',
    },
    {
      'title': 'quickActions.course_stats'.tr(),
      'icon': Symbols.school_rounded,
      'id': 'course_stats',
    },
    {
      'title': 'quickActions.eca'.tr(),
      'icon': Symbols.padel_rounded,
      'id': 'eca',
    },
    {
      'title': 'quickActions.mentoring'.tr(),
      'icon': Symbols.psychiatry_rounded,
      'id': 'mentoring',
    },
    {
      'title': 'quickActions.global_citizenship'.tr(),
      'icon': Symbols.diversity_2_rounded,
      'id': 'global_citizenship',
    },
    {
      'title': 'quickActions.surveys'.tr(),
      'icon': Symbols.rate_review_rounded,
      'id': 'surveys',
    },
    {
      'title': 'quickActions.course_selection'.tr(),
      'icon': Symbols.book_rounded,
      'id': 'course_selection',
    },
    {
      'title': 'quickActions.exam_entry'.tr(),
      'icon': Symbols.assignment_turned_in_rounded,
      'id': 'exam_entry',
    },
    {
      'title': 'quickActions.insurance'.tr(),
      'icon': Symbols.health_and_safety_rounded,
      'id': 'insurance',
    },
    {
      'title': 'quickActions.e_agreement'.tr(),
      'icon': Symbols.contract_rounded,
      'id': 'e_agreement',
    },
    {
      'title': 'quickActions.special_consideration'.tr(),
      'icon': Symbols.bookmark_heart_rounded,
      'id': 'special_consideration',
    },
    {
      'title': 'quickActions.id_card'.tr(),
      'icon': Symbols.id_card_rounded,
      'id': 'id_card',
    },
    {
      'title': 'quickActions.university_application'.tr(),
      'icon': Symbols.school_rounded,
      'id': 'university_application',
    },
    {
      'title': 'quickActions.certifications'.tr(),
      'icon': Symbols.license_rounded,
      'id': 'certifications',
    },
    {
      'title': 'quickActions.settings'.tr(),
      'icon': Symbols.settings_rounded,
      'id': 'settings',
    },
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
