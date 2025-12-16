import 'package:flutter/material.dart';
import 'package:opencms/features/auth/services/login_state.dart';
import 'package:opencms/di/locator.dart';
import 'package:opencms/features/shared/pages/notices.dart';
import '../../attendance/views/pages/attendance.dart';
import '../../assessment/views/pages/assessment.dart';
import '../../homework/views/pages/homework.dart';
import '../../web_cms/views/pages/web_cms.dart';
import '../../free_classroom/views/pages/free_classrooms.dart';
import '../../calendar/views/pages/school_calendar.dart';
import '../../user/views/pages/profile.dart';
import '../../timetable/views/pages/timetable.dart';
import '../../reports/views/pages/reports.dart';
import '../../referral/views/pages/referral_comments.dart';
import '../../navigations/views/app_navigation_controller.dart';
import '../../settings/settings.dart';
import '../constants/api_endpoints.dart';
import '../views/widgets/custom_app_bar.dart';

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

class UnknownActionPage extends StatelessWidget {
  final String id;
  final String title;
  const UnknownActionPage({super.key, required this.id, required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: Text(title.isNotEmpty ? title : id)),
      body: Center(child: Text('Page for "$id" not implemented yet')),
    );
  }
}

Future<Widget> buildActionPage(Map<String, dynamic> action) async {
  final username = di<LoginState>().currentUsername;
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
      return const ReferralCommentsPage();
    case 'calendar':
      return const SchoolCalendarPage();
    case 'notice':
      return const NoticesPage(initialTabIndex: 0);
    case 'daily_bulletin':
      return const NoticesPage(initialTabIndex: 1);
    case 'events':
      return const NoticesPage(initialTabIndex: 2);
    case 'homeworks':
      return const HomeworkPage();
    case 'documents':
      return const WebCmsPage(
        initialUrl: '${API.legacyBaseUrl}/file/list/student/',
        windowTitle: 'Documents',
      );
    case 'available_classrooms':
      return const FreeClassroomsPage();
    case 'maintenance':
      return WebCmsPage(
        initialUrl:
            '${API.legacyCMSBaseUrl}/$username/repairment/list/',
        windowTitle: 'Maintenance',
      );
    case 'leave_requests':
      return WebCmsPage(
        initialUrl:
            '${API.legacyCMSBaseUrl}/$username/studentleave/list/ps/',
        windowTitle: 'Leave Requests',
      );
    case 'student_profile':
      return const ProfilePage();
    case 'course_stats':
      return AttendancePage(initialTabIndex: 1);
    case 'eca':
      return WebCmsPage(
        initialUrl:
            '${API.legacyCMSBaseUrl}/$username/ecaclass/index/',
        windowTitle: 'ECA',
      );
    case 'mentoring':
      return WebCmsPage(
        initialUrl:
            '${API.legacyCMSBaseUrl}/$username/mentoring/list/',
        windowTitle: 'Mentoring',
      );
    case 'global_citizenship':
      return WebCmsPage(
        initialUrl: '${API.legacyCMSBaseUrl}/$username/achievement/',
        windowTitle: 'Global Citizenship',
      );
    case 'surveys':
      return WebCmsPage(
        initialUrl: '${API.legacyCMSBaseUrl}/$username/survey/',
        windowTitle: 'Surveys',
      );
    case 'course_selection':
      return WebCmsPage(
        initialUrl: '${API.legacyCMSBaseUrl}/$username/course/select/',
        windowTitle: 'Course Selection',
      );
    case 'exam_entry':
      return WebCmsPage(
        initialUrl:
            '${API.legacyCMSBaseUrl}/$username/report/cie_statement_self/',
        windowTitle: 'Exam Entry',
      );
    case 'insurance':
      return WebCmsPage(
        initialUrl: '${API.legacyCMSBaseUrl}/$username/insurance/',
        windowTitle: 'Insurance',
      );
    case 'e_agreement':
      return WebCmsPage(
        initialUrl:
            '${API.legacyCMSBaseUrl}/jump_into_internal/econtract:list/',
        windowTitle: 'E-Agreement',
      );
    case 'special_consideration':
      return WebCmsPage(
        initialUrl:
            '${API.legacyCMSBaseUrl}/$username/special_consideration/',
        windowTitle: 'Special Concern',
      );
    case 'id_card':
      return WebCmsPage(
        initialUrl:
            '${API.legacyCMSBaseUrl}/$username/student_idcard_upload/',
        windowTitle: 'ID Card',
      );
    case 'university_application':
      return WebCmsPage(
        initialUrl: '${API.legacyCMSBaseUrl}/$username/uniapp/',
        windowTitle: 'University Application',
      );
    case 'certifications':
      return WebCmsPage(
        initialUrl:
            '${API.legacyCMSBaseUrl}/$username/certification/create/',
        windowTitle: 'Certifications',
      );
    case 'settings':
      return const SettingsPage();
    default:
      return UnknownActionPage(
        id: id,
        title: (action['title'] as String?) ?? id,
      );
  }
}
