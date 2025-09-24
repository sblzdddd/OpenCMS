import '../../../data/constants/api_endpoints.dart';
import '../auth_service_base.dart';
import 'package:flutter/foundation.dart';

/// Acquire legacy (old CMS) cookies by exchanging a legacy token and visiting legacy site.
/// Returns true on success, false otherwise.
Future<bool> refreshLegacyCookies(AuthServiceBase authService) async {
  try {
    final info = authService.userInfo;
    if (info == null) {
      debugPrint('LegacyFunctions: refreshLegacyCookies skipped - missing user info');
      return false;
    }
    final username = info.username;
    if (username.isEmpty) {
      debugPrint('LegacyFunctions: refreshLegacyCookies skipped - missing username');
      return false;
    }

    // Exchange for legacy token
    final tokenResp = await authService.httpService.get(
      ApiConstants.legacyTokenUrlForHref,
      refresh: true,
    );
    final data = tokenResp.data ?? {};
    final code = (data['code'] ?? '').toString();
    final iv = (data['iv'] ?? '').toString();
    if (code.isEmpty || iv.isEmpty) {
      debugPrint('LegacyFunctions: Legacy token response missing code/iv');
      throw Exception('Legacy token response missing code/iv');
    }

    // Visit legacy site to set cookies (server will set cookies and redirect)
    final legacyUrl = '/$username/?token=$code&iv=$iv';
    // Follow redirects to properly set cookies on the final domain
    final visitResp = await authService.httpService.getLegacy(
      legacyUrl,
      refresh: true,
      followRedirects: false,
    );

    // Success if we no longer see the loading placeholder
    final ok = !visitResp.data.contains('<div>Loading...</div>');
    if (!ok) {
      debugPrint('LegacyFunctions: Legacy visit may not have initialized cookies. Status: ${visitResp.statusCode}');
    }
    debugPrint('LegacyFunctions: Legacy cookies refreshed');
    return ok;
  } catch (e) {
    debugPrint('LegacyFunctions: refreshLegacyCookies exception: $e');
    return false;
  }
}
