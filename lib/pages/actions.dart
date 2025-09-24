import 'package:flutter/material.dart';
import 'package:opencms/pages/actions/notices.dart';
import 'actions/attendance.dart';
import 'actions/assessment.dart';
import 'actions/homework.dart';
import 'actions/web_cms.dart';
import 'actions/free_classrooms.dart';
import '../data/constants/quick_actions.dart';
import '../ui/shared/navigations/app_navigation_controller.dart';
import 'actions/timetable.dart';
import 'settings/settings_page.dart';
import 'actions/reports.dart';
import '../ui/referral/views/referral_comments_view.dart';
import '../ui/calendar/calendar_ui.dart';
import '../ui/profile/pages/profile_page.dart';
import '../services/auth/auth_service.dart';
import '../data/constants/api_endpoints.dart';

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

Future<Widget> openMaintenancePage() async {
  final username = await AuthService().fetchCurrentUsername();
  return WebCmsPage(initialUrl: '${ApiConstants.legacyCMSBaseUrl}/$username/repairment/list/', windowTitle: 'Maintenance');
}

Future<Widget> buildEcaPage() async {
  final username = await AuthService().fetchCurrentUsername();
  return WebCmsPage(initialUrl: '${ApiConstants.legacyCMSBaseUrl}/$username/ecaclass/index/', windowTitle: 'ECA');
}

Future<Widget> buildLeaveRequestsPage() async {
  final username = await AuthService().fetchCurrentUsername();
  return WebCmsPage(initialUrl: '${ApiConstants.legacyCMSBaseUrl}/$username/studentleave/list/ps/', windowTitle: 'Leave Requests');
}

Future<Widget> buildActionPage(Map<String, dynamic> action) async {
  final String id = action['id'] as String;
  switch (id) {
    case 'webcms':
      return const WebCmsPage();
    case 'timetable':
      return const TimetablePage(initialTabIndex: 0);
    case 'exam':
      return const TimetablePage(initialTabIndex: 1);
    case 'attendance':
      return const AttendancePage(initialTabIndex: 0);
    case 'reports':
      return const ReportsPage(initialTabIndex: 0);
    case 'assessment':
      return const AssessmentPage();
    case 'comments':
      return const ReferralCommentsView();
    case 'calendar':
      return const CalendarPage();
    case 'notice':
      return const NoticesPage(initialTabIndex: 0);
    case 'bulletin':
      return const NoticesPage(initialTabIndex: 1);
    case 'events':
      return const NoticesPage(initialTabIndex: 2);
    case 'homeworks':
      return const HomeworkPage();
    case 'documents':
      return const WebCmsPage(initialUrl: '${ApiConstants.legacyBaseUrl}/file/list/student/', windowTitle: 'Documents');
    case 'available_classrooms':
      return const FreeClassroomsPage();
    case 'maintenance':
      return openMaintenancePage();
    case 'leave_requests':
      return buildLeaveRequestsPage();
    case 'student_profile':
      return const ProfilePage();
    case 'course_stats':
      return AttendancePage(initialTabIndex: 1);
    case 'eca':
      return buildEcaPage();
    case 'settings':
      return const SettingsPage();
    default:
      return UnknownActionPage(
        id: id,
        title: (action['title'] as String?) ?? id,
      );
  }
}


