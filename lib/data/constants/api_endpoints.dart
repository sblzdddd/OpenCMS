/// API Constants for OpenCMS
/// 
/// This module contains all API endpoint configurations and constants
/// used throughout the application.
library;

class ApiConstants {
  // Base API configuration
  static const String baseDomain = 'a''le''vel''.c''o''m.c''n';
  static const String baseUrl = 'https://c''ms.$baseDomain';
  static const String baseApiUrl = '$baseUrl/api';
  
  // Legacy CMS base (old domain)
  static const String legacyBaseUrl = 'https://w''ww.$baseDomain';
  static const String legacyCMSBaseUrl = '$legacyBaseUrl/user';
  
  // Authentication endpoint
  static const String loginEndpoint = '/token/';
  // new CMS refresh token
  static const String tokenRefreshEndpoint = '/token/refresh/';
  static const String tencentCaptchaAppId = '194431589';
  
  // Legacy token exchange endpoint in new CMS. Provide an href (e.g. "/student/examtimetable/")
  static const String legacyTokenUrlForHref = '/account/legacy_token/?href=%2F%3Fredirect%3Dfalse';
  
  // Account/User endpoint for validating session cookies
  static const String accountUserUrl = '/account/user/';
  // User profile endpoints
  static const String userProfileUrl = '/legacy/students/my/';

  // Course Timetable endpoint
  // parameters: year (academic year), date (today's date in yyyy-mm-dd e.g. 2025-08-14)
  static const String courseTimetableUrl = '/legacy/students/my/timetable/';
  // Course Stats endpoint
  // parameters: year (academic year)
  static const String courseStatsUrl = '/legacy/students/my/course_stats/';
  // Attendance endpoint
  // parameters: start_date (yyyy-mm-dd), end_date (yyyy-mm-dd)
  static const String attendanceUrl = '/legacy/students/my/attendance/';
  
  // Homework endpoint  
  // parameters: year (academic year)
  static const String homeworkUrl = '/legacy/students/my/homework/';
  
  // Reports endpoints
  // parameters: none for list, exam ID for detail
  static const String reportsListUrl = '/legacy/students/my/reports/';
  static String reportsDetailUrl(int examId) => '/legacy/students/my/reports/$examId/';
  
  // Assessments endpoint
  // parameters: year (academic year)
  static const String assessmentsUrl = '/legacy/students/my/assessments/';
  
  // Free classrooms endpoint (legacy)
  // parameters: b (date in yyyy-mm-dd format), w (week period like W1)
  static const String freeClassroomsUrl = '/classroom/get_freeroom_by_ajax/';
  
  // HTTP configuration
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration solveCaptchaPollInterval = Duration(seconds: 1);
  static const int solveCaptchaMaxPollAttempts = 20; // ~60s

  // Referer
  // used for accountUserUrl
  static const String cmsReferer = '$baseUrl/cms';
  static const String legacyCMSReferer = legacyCMSBaseUrl;

  // Notification endpoint
  static const String notificationUrl = '/legacy/notifications/my/';
  static String notificationDetailUrl(String username, int id) => '/$username/viewtj/$id/';

  // Daily Bulletin endpoint
  static String dailyBulletinUrl(String date) => '/legacy/bulletin/$date/';
  static String dailyBulletinDetailUrl(String username, int id) => '/$username/daily_bulletin/view/$id/';

  // Referral comments endpoint
  static const String referralUrl = '/legacy/students/my/referral/';

  // Calendar endpoints (legacy)
  static const String calendarUrl = '/getcalendar/';
  static const String calendarDetailUrl = '/getcalendarbyid/';
  static const String calendarCommentUrl = '/getcommentbyid/';
  
  // New CMS calendar by date endpoint (returns list for a given yyyy-mm-dd)
  static String calendarByDateUrl(String yyyyMmDd) => '/legacy/calendar/$yyyyMmDd/';

  static const String classroomsList = "(1006),(1008),(1009),(1010),A201,A202,A205,A206,A207,A208,A210,A211,A212,A215,A216,A219,A220,A301,A302,A305,A306,A307,A308,A310,A311,A314,A315,A318,A319,A401,A402,A406,A407,A408,A409,A410,A411,A414,A415,A416,A419,A501,A502,A505,A506,A507,A508,A509,A510,A511,A519,A606,A610,A611,A612,A613,A616,A617,(A704),(A705),(A706),(A707),(A710),(A711),(A715),(A803),(A805),(A806),(A809),B221,B320,B323,B324,B325,B326,B327,B329,B330,B331,B332,B333,B421,B423,B424,B427,B430,B431,B432,B433,B522,B523,B524,B525,B526,B530,B531,B532,B533,B534,(B618),(B619),(B621),(B622),(B624),(B629),(B631),(B719),(B721),(B722),(B724),(B726),(B728),(B731),(B812),(B814),(B815),(B817),(B819),(B821),(G019),G030,G031,(G117),(G118),(G119B),";
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Referer': cmsReferer,
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36',
  };

  static const Map<String, String> legacyHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Referer': legacyCMSReferer,
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36',
  };
}
