import 'package:flutter/foundation.dart';
import 'package:opencms/features/core/di/locator.dart';
import 'package:opencms/features/core/networking/http_service.dart';
import 'package:platform_device_id/platform_device_id.dart';

class AutoCaptchaService {
  /// Get captcha ticket from the auto captcha service
  /// Returns the captcha ticket data if successful, false otherwise
  Future<dynamic> getTicket() async {
    try {
      String? deviceId = await PlatformDeviceId.getDeviceId;
      if (deviceId == null || deviceId.isEmpty) return false;
      return false;
      debugPrint('AutoCaptchaFunctions: Attempting to get captcha ticket');

      final response = await di<HttpService>().get("", refresh: true);

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
}
