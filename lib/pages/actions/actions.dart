import 'package:flutter/material.dart';
import 'attendance.dart';
import 'homework.dart';
import 'web_cms.dart';
import '../../data/constants/quick_actions_constants.dart';
import '../../ui/shared/navigations/app_navigation_controller.dart';
import 'timetable.dart';
import '../../pages/settings_page.dart';
import 'reports.dart';

String _actionTitle(String id) {
  return QuickActionsConstants.getActionById(id)?['title'] as String? ?? id;
}

/// Returns true if the action is handled by switching the bottom/rail navigation.
/// timetable -> tab 1, homeworks -> tab 2, assessment -> tab 3
bool handleActionNavigation(BuildContext context, Map<String, dynamic> action) {
  final String id = action['id'] as String;
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

class ActionPageScaffold extends StatelessWidget {
  final String id;
  const ActionPageScaffold(this.id, {super.key});

  @override
  Widget build(BuildContext context) {
    final String title = _actionTitle(id);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('$title page coming soon'),
      ),
    );
  }
}

class CourseTimetablePage extends StatelessWidget {
  const CourseTimetablePage({super.key});
  @override
  Widget build(BuildContext context) {
    // Try to handle via navigation first
    if (handleActionNavigation(context, {'id': 'timetable'})) {
      return const SizedBox.shrink(); // This won't be shown
    }
    return const ActionPageScaffold('timetable');
  }
}

class ExamTimetablePage extends StatelessWidget {
  const ExamTimetablePage({super.key});
  @override
  Widget build(BuildContext context) {
    // Try to handle via navigation first and switch to inner tab 2
    if (handleActionNavigation(context, {'id': 'exam'})) {
      return const SizedBox.shrink(); // This won't be shown
    }
    return const ActionPageScaffold('exam');
  }
}

class AssessmentsFeedbackPage extends StatelessWidget {
  const AssessmentsFeedbackPage({super.key});
  @override
  Widget build(BuildContext context) {
    // Try to handle via navigation first
    if (handleActionNavigation(context, {'id': 'feedback'})) {
      return const SizedBox.shrink(); // This won't be shown
    }
    return const ActionPageScaffold('assessment');
  }
}

class TeacherCommentsPage extends StatelessWidget {
  const TeacherCommentsPage({super.key});
  @override
  Widget build(BuildContext context) => const ActionPageScaffold('comments');
}

class SchoolCalendarPage extends StatelessWidget {
  const SchoolCalendarPage({super.key});
  @override
  Widget build(BuildContext context) => const ActionPageScaffold('calendar');
}

class NoticesPage extends StatelessWidget {
  const NoticesPage({super.key});
  @override
  Widget build(BuildContext context) => const ActionPageScaffold('notice');
}

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});
  @override
  Widget build(BuildContext context) => const ActionPageScaffold('events');
}

class HomeworksPage extends StatelessWidget {
  const HomeworksPage({super.key});
  @override
  Widget build(BuildContext context) {
    // Try to handle via navigation first
    if (handleActionNavigation(context, {'id': 'homeworks'})) {
      return const SizedBox.shrink(); // This won't be shown
    }
    return const ActionPageScaffold('homeworks');
  }
}

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});
  @override
  Widget build(BuildContext context) => const ActionPageScaffold('documents');
}

class AvailableClassroomsPage extends StatelessWidget {
  const AvailableClassroomsPage({super.key});
  @override
  Widget build(BuildContext context) => const ActionPageScaffold('available_classrooms');
}

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});
  @override
  Widget build(BuildContext context) => const ActionPageScaffold('maintenance');
}

class LeaveRequestsPage extends StatelessWidget {
  const LeaveRequestsPage({super.key});
  @override
  Widget build(BuildContext context) => const ActionPageScaffold('leave_requests');
}

class StudentProfilePage extends StatelessWidget {
  const StudentProfilePage({super.key});
  @override
  Widget build(BuildContext context) => const ActionPageScaffold('student_profile');
}

class CourseStatsPage extends StatelessWidget {
  const CourseStatsPage({super.key});
  @override
  Widget build(BuildContext context) => const ActionPageScaffold('course_stats');
}

class EcaPage extends StatelessWidget {
  const EcaPage({super.key});
  @override
  Widget build(BuildContext context) => const ActionPageScaffold('eca');
}

class UnknownActionPage extends StatelessWidget {
  final String id;
  final String title;
  const UnknownActionPage({super.key, required this.id, required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title.isNotEmpty ? title : id)),
      body: Center(child: Text('Page for "$id" not implemented yet')),
    );
  }
}

Widget buildActionPage(Map<String, dynamic> action) {
  final String id = action['id'] as String;
  switch (id) {
    case 'webcms':
      return const WebCmsPage();
    case 'timetable':
      return const TimetablePage(initialTabIndex: 0);
    case 'exam':
      return const TimetablePage(initialTabIndex: 1);
    case 'attendance':
      return AttendancePage(initialTabIndex: 0);
    case 'reports':
      return const ReportsPage(initialTabIndex: 0);
    case 'assessment':
      return const AssessmentsFeedbackPage();
    case 'comments':
      return const TeacherCommentsPage();
    case 'calendar':
      return const SchoolCalendarPage();
    case 'notice':
      return const NoticesPage();
    case 'events':
      return const EventsPage();
    case 'homeworks':
      return const HomeworkPage(initialTabIndex: 0);
    case 'documents':
      return const DocumentsPage();
    case 'available_classrooms':
      return const AvailableClassroomsPage();
    case 'maintenance':
      return const MaintenancePage();
    case 'leave_requests':
      return const LeaveRequestsPage();
    case 'student_profile':
      return const StudentProfilePage();
    case 'course_stats':
      return AttendancePage(initialTabIndex: 1);
    case 'eca':
      return const EcaPage();
    case 'settings':
      return const SettingsPage();
    default:
      return UnknownActionPage(
        id: id,
        title: (action['title'] as String?) ?? id,
      );
  }
}


