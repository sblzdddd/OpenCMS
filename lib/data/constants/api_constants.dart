/// API Constants for OpenCMS
/// 
/// This module contains all API endpoint configurations and constants
/// used throughout the application.
library;

class ApiConstants {
  // Base API configuration
  static const String baseUrl = 'https://cms.alevel.com.cn';
  static const String baseApiUrl = '$baseUrl/api';
  
  // Legacy CMS base (old domain)
  static const String legacyBaseUrl = 'https://www.alevel.com.cn';
  static const String legacyCMSBaseUrl = '$legacyBaseUrl/user';
  
  // Authentication endpoint
  static const String loginEndpoint = '/token/';
  // new CMS refresh token
  static const String tokenRefreshEndpoint = '/token/refresh/';
  static const String tencentCaptchaAppId = '194431589';
  
  // Legacy token exchange endpoint in new CMS. Provide an href (e.g. "/student/examtimetable/")
  static String legacyTokenUrlForHref() {
    return '/account/legacy_token/?href=${Uri.encodeComponent('/?redirect=false')}';
  }
  
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
  // parameters: fy (academic year), courseid (optional), duedate (optional), duedate2 (optional)
  static const String homeworkUrl = '/legacy/students/my/homework/';
  
  // Third-party captcha solver (solvecaptcha) configuration
  static const String solveCaptchaBaseUrl = 'https://api.solvecaptcha.com';
  static const String solveCaptchaInEndpoint = '$solveCaptchaBaseUrl/in.php';
  static const String solveCaptchaResEndpoint = '$solveCaptchaBaseUrl/res.php';
  static const String solveCaptchaTencentMethod = 'tencent';
  static const String solveCaptchaPageUrl = '$baseUrl/cms/auth/login';
  
  // HTTP configuration
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration solveCaptchaPollInterval = Duration(seconds: 1);
  static const int solveCaptchaMaxPollAttempts = 20; // ~60s

  // Referer
  // used for accountUserUrl
  static const String cmsReferer = '$baseUrl/cms';
  static const String legacyCMSReferer = legacyCMSBaseUrl;
  
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
  };
}
