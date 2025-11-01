import '../auth_service_base.dart';
import 'package:flutter/foundation.dart';

/// Get captcha ticket from the auto captcha service
/// Returns the captcha ticket data if successful, false otherwise
Future<dynamic> getTicket(AuthServiceBase authService) async {
  try {
    return false;
    debugPrint('AutoCaptchaFunctions: Attempting to get captcha ticket');

    final response = await authService.httpService.get("", refresh: true);

    if (response.statusCode == 200) {
      debugPrint('AutoCaptchaFunctions: Get ticket successful');
      return response.data['data'];
    } else {
      debugPrint(
        'AutoCaptchaFunctions: Get ticket failed with status: ${response.statusCode}',
      );
      debugPrint('AutoCaptchaFunctions: Get ticket response: ${response.data}');
      return false;
    }
  } catch (e) {
    debugPrint('AutoCaptchaFunctions: Get ticket exception: $e');
    return false;
  }
}
