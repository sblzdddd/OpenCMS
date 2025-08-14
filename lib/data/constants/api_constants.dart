/// API Constants for OpenCMS
/// 
/// This module contains all API endpoint configurations and constants
/// used throughout the application.
library;

class ApiConstants {
  // Base API configuration
  static const String baseUrl = 'https://cms.alevel.com.cn';
  static const String apiPath = '/api';
  static const String baseApiUrl = '$baseUrl$apiPath';
  
  // Legacy CMS base (old domain)
  static const String legacyBaseUrl = 'https://www.alevel.com.cn';
  
  // Authentication endpoints
  static const String loginUrl = '$baseApiUrl/token/';
  // refresh token
  static const String tokenRefreshUrl = '$baseApiUrl/token/refresh/';
  static const String tencentCaptchaAppId = '194431589';
  
  // Legacy token exchange endpoint. Provide an href (e.g. "/student/examtimetable/")
  static String legacyTokenUrlForHref() {
    return '$baseApiUrl/account/legacy_token/?href=${Uri.encodeComponent('/?redirect=false')}';
  }
  
  // Account/User endpoint for validating session cookies
  static const String accountUserUrl = '$baseApiUrl/account/user/';
  // User profile endpoints
  static const String userProfileUrl = '$baseApiUrl/legacy/students/my/';

  // Course Timetable endpoint
  // parameters: year (academic year), date (today's date in yyyy-mm-dd e.g. 2025-08-14)
  static const String courseTimetableUrl = '$baseApiUrl/legacy/students/my/timetable/';
  // Course Stats endpoint
  // parameters: year (academic year)
  static const String courseStatsUrl = '$baseApiUrl/legacy/students/my/course_stats/';
  // Attendance endpoint
  // parameters: start_date (yyyy-mm-dd), end_date (yyyy-mm-dd)
  static const String attendanceUrl = '$baseApiUrl/legacy/students/my/attendance/';
  
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
  // used for loginUrl
  static const String loginReferer = '$baseUrl/cms/auth/login';
  // used for courseTimetableUrl, courseStatsUrl
  static const String timetableReferer = '$baseUrl/cms/students/my/timetable/';
  // used for legacy site navigation
  static String legacyUserBaseUrl(String username) => '$legacyBaseUrl/user/$username';
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36',
  };
}
