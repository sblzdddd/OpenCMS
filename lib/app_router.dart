import 'package:flutter/material.dart';
import 'package:opencms/di/locator.dart';
import 'package:opencms/features/assessment/views/pages/assessment.dart';
import 'package:opencms/features/attendance/views/pages/attendance.dart';
import 'package:opencms/features/auth/services/login_state.dart';
import 'package:opencms/features/auth/views/pages/login.dart';
import 'package:opencms/features/calendar/views/pages/school_calendar.dart';
import 'package:opencms/features/free_classroom/views/pages/free_classrooms.dart';
import 'package:opencms/features/home/views/pages/new_home.dart';
import 'package:opencms/features/homework/views/pages/homework.dart';
import 'package:opencms/features/referral/views/pages/referral_comments.dart';
import 'package:opencms/features/reports/views/pages/reports.dart';
import 'package:opencms/features/settings/settings.dart';
import 'package:opencms/features/shared/constants/api_endpoints.dart';
import 'package:opencms/features/shared/pages/notices.dart';
import 'package:opencms/features/shared/views/widgets/custom_app_bar.dart';
import 'package:opencms/features/timetable/views/pages/timetable.dart';
import 'package:opencms/features/user/views/pages/profile.dart';
import 'package:opencms/features/web_cms/views/pages/web_cms.dart';

class UnknownActionPage extends StatelessWidget {
  final String id;
  const UnknownActionPage({super.key, required this.id});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: Text(id)),
      body: Center(child: Text('Page for "$id" not implemented yet')),
    );
  }
}

class AppRouter {
  static const String login = '/login';
  static const String home = '/home';

  // Actions
  static const String webcms = '/webcms';
  static const String timetable = '/timetable';
  static const String exam = '/exam';
  static const String attendance = '/attendance';
  static const String reports = '/reports';
  static const String assessment = '/assessment';
  static const String comments = '/comments';
  static const String calendar = '/calendar';
  static const String notice = '/notice';
  static const String dailyBulletin = '/daily_bulletin';
  static const String events = '/events';
  static const String homeworks = '/homeworks';
  static const String documents = '/documents';
  static const String availableClassrooms = '/available_classrooms';
  static const String maintenance = '/maintenance';
  static const String leaveRequests = '/leave_requests';
  static const String studentProfile = '/student_profile';
  static const String courseStats = '/course_stats';
  static const String eca = '/eca';
  static const String mentoring = '/mentoring';
  static const String globalCitizenship = '/global_citizenship';
  static const String surveys = '/surveys';
  static const String courseSelection = '/course_selection';
  static const String examEntry = '/exam_entry';
  static const String insurance = '/insurance';
  static const String eAgreement = '/e_agreement';
  static const String specialConsideration = '/special_consideration';
  static const String idCard = '/id_card';
  static const String universityApplication = '/university_application';
  static const String certifications = '/certifications';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    String routeName = routeSettings.name ?? '';
    Widget page = getWidget(routeName);
    return MaterialPageRoute(builder: (_) => page, settings: routeSettings);
  }

  static Widget getWidget(String routeName) {
    if (!routeName.startsWith('/')) {
      routeName = '/$routeName';
    }
    final username = di<LoginState>().currentUsername;

    switch (routeName) {
      case login:
        return const LoginPage();
      case home:
        return const NewHomePage();
      case webcms:
        return const WebCmsPage();
      case timetable:
        return const TimetablePage(initialTabIndex: 0);
      case exam:
        return const TimetablePage(initialTabIndex: 1);
      case attendance:
        return const AttendancePage(initialTabIndex: 0);
      case reports:
        return const ReportsPage(initialTabIndex: 0);
      case assessment:
        return const AssessmentPage();
      case comments:
        return const ReferralCommentsPage();
      case calendar:
        return const SchoolCalendarPage();
      case notice:
        return const NoticesPage(initialTabIndex: 0);
      case dailyBulletin:
        return const NoticesPage(initialTabIndex: 1);
      case events:
        return const NoticesPage(initialTabIndex: 2);
      case homeworks:
        return const HomeworkPage();
      case documents:
        return const WebCmsPage(
          initialUrl: '${API.legacyBaseUrl}/file/list/student/',
          windowTitle: 'Documents',
        );
      case availableClassrooms:
        return const FreeClassroomsPage();
      case maintenance:
        return WebCmsPage(
          initialUrl: '${API.legacyCMSBaseUrl}/$username/repairment/list/',
          windowTitle: 'Maintenance',
        );
      case leaveRequests:
        return WebCmsPage(
          initialUrl: '${API.legacyCMSBaseUrl}/$username/studentleave/list/ps/',
          windowTitle: 'Leave Requests',
        );
      case studentProfile:
        return const ProfilePage();
      case courseStats:
        return const AttendancePage(initialTabIndex: 1);
      case eca:
        return WebCmsPage(
          initialUrl: '${API.legacyCMSBaseUrl}/$username/ecaclass/index/',
          windowTitle: 'ECA',
        );
      case mentoring:
        return WebCmsPage(
          initialUrl: '${API.legacyCMSBaseUrl}/$username/mentoring/list/',
          windowTitle: 'Mentoring',
        );
      case globalCitizenship:
        return WebCmsPage(
          initialUrl: '${API.legacyCMSBaseUrl}/$username/achievement/',
          windowTitle: 'Global Citizenship',
        );
      case surveys:
        return WebCmsPage(
          initialUrl: '${API.legacyCMSBaseUrl}/$username/survey/',
          windowTitle: 'Surveys',
        );
      case courseSelection:
        return WebCmsPage(
          initialUrl: '${API.legacyCMSBaseUrl}/$username/course/select/',
          windowTitle: 'Course Selection',
        );
      case examEntry:
        return WebCmsPage(
          initialUrl:
              '${API.legacyCMSBaseUrl}/$username/report/cie_statement_self/',
          windowTitle: 'Exam Entry',
        );
      case insurance:
        return WebCmsPage(
          initialUrl: '${API.legacyCMSBaseUrl}/$username/insurance/',
          windowTitle: 'Insurance',
        );
      case eAgreement:
        return WebCmsPage(
          initialUrl:
              '${API.legacyCMSBaseUrl}/jump_into_internal/econtract:list/',
          windowTitle: 'E-Agreement',
        );
      case specialConsideration:
        return WebCmsPage(
          initialUrl:
              '${API.legacyCMSBaseUrl}/$username/special_consideration/',
          windowTitle: 'Special Concern',
        );
      case idCard:
        return WebCmsPage(
          initialUrl:
              '${API.legacyCMSBaseUrl}/$username/student_idcard_upload/',
          windowTitle: 'ID Card',
        );
      case universityApplication:
        return WebCmsPage(
          initialUrl: '${API.legacyCMSBaseUrl}/$username/uniapp/',
          windowTitle: 'University Application',
        );
      case certifications:
        return WebCmsPage(
          initialUrl: '${API.legacyCMSBaseUrl}/$username/certification/create/',
          windowTitle: 'Certifications',
        );
      case settings:
        return const SettingsPage();

      default:
        // Handle unknown routes, possibly extracting ID from path
        String id = routeName.replaceAll('/', '');
        return UnknownActionPage(id: id);
    }
  }
}
