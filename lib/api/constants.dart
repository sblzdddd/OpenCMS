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
  
  // Authentication endpoints
  static const String tokenEndpoint = '/token/';
  static const String loginUrl = '$baseApiUrl$tokenEndpoint';
  static const String tencentCaptchaAppId = '194431589';
  
  // Account/User endpoint for validating session cookies
  static const String accountUserEndpoint = '/account/user/';
  static const String accountUserUrl = '$baseApiUrl$accountUserEndpoint';
  static const String cmsReferer = 'https://cms.alevel.com.cn/cms';
  
  // Third-party captcha solver (solvecaptcha) configuration
  static const String solveCaptchaBaseUrl = 'https://api.solvecaptcha.com';
  static const String solveCaptchaInEndpoint = '$solveCaptchaBaseUrl/in.php';
  static const String solveCaptchaResEndpoint = '$solveCaptchaBaseUrl/res.php';
  static const String solveCaptchaTencentMethod = 'tencent';
  static const String solveCaptchaPageUrl = 'https://example.com';
  
  // HTTP configuration
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration solveCaptchaPollInterval = Duration(seconds: 1);
  static const int solveCaptchaMaxPollAttempts = 20; // ~60s
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36',
  };
}
