import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class SolveCaptchaResult {
  final bool isSuccess;
  final String message;
  final Map<String, dynamic>? captchaData;

  const SolveCaptchaResult({
    required this.isSuccess,
    required this.message,
    this.captchaData,
  });
}

/// Service that integrates with solvecaptcha.com to automatically solve Tencent captcha
class SolveCaptchaService {
  static final SolveCaptchaService _instance = SolveCaptchaService._internal();
  factory SolveCaptchaService() => _instance;
  SolveCaptchaService._internal();

  Future<SolveCaptchaResult> solveWithApiKey(String apiKey) async {
    try {
      final taskId = await _submitTask(apiKey);
      if (taskId == null) {
        return const SolveCaptchaResult(
          isSuccess: false,
          message: 'Failed to submit captcha task',
        );
      }

      final solved = await _pollForResult(apiKey, taskId);
      return solved;
    } catch (e) {
      return SolveCaptchaResult(isSuccess: false, message: 'Solver error: $e');
    }
  }

  Future<String?> _submitTask(String apiKey) async {
    final uri = Uri.parse(ApiConstants.solveCaptchaInEndpoint);

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'method': ApiConstants.solveCaptchaTencentMethod,
        'pageurl': ApiConstants.solveCaptchaPageUrl,
        'app_id': ApiConstants.tencentCaptchaAppId,
        'key': apiKey,
      },
    ).timeout(ApiConstants.defaultTimeout);

    final body = response.body.trim();
    print('submitTask response: $body');
    if (body.startsWith('OK|')) {
      return body.substring(3);
    }
    return null;
  }

  Future<SolveCaptchaResult> _pollForResult(String apiKey, String taskId) async {
    for (int attempt = 0; attempt < ApiConstants.solveCaptchaMaxPollAttempts; attempt++) {
      final response = await http.get(
        Uri.parse('${ApiConstants.solveCaptchaResEndpoint}?id=$taskId&action=get&key=$apiKey')
      ).timeout(ApiConstants.defaultTimeout);

      final body = response.body.trim();
      print('pollForResult response: $body');
      if (body.startsWith('OK|')) {
        final jsonPart = body.substring(3);
        try {
          final parsed = jsonDecode(jsonPart) as Map<String, dynamic>;
          return SolveCaptchaResult(
            isSuccess: true,
            message: 'Solved',
            captchaData: parsed,
          );
        } catch (_) {
          return const SolveCaptchaResult(
            isSuccess: false,
            message: 'Invalid JSON in solver response',
          );
        }
      }

      if (body == 'CAPCHA_NOT_READY' || body == 'CAPTCHA_NOT_READY') {
        await Future.delayed(ApiConstants.solveCaptchaPollInterval);
        continue;
      }

      // Any other non-OK response indicates an error; stop polling early
      return SolveCaptchaResult(
        isSuccess: false,
        message: body.isEmpty ? 'Unknown solver error' : body,
      );
    }

    return const SolveCaptchaResult(
      isSuccess: false,
      message: 'Solver timeout waiting for result',
    );
  }
}


