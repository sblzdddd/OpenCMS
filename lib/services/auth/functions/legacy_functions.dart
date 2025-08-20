import '../../../data/constants/api_constants.dart';
import '../auth_service_base.dart';

/// Acquire legacy (old CMS) cookies by exchanging a legacy token and visiting legacy site.
/// Returns true on success, false otherwise.
Future<bool> refreshLegacyCookies(AuthServiceBase authService) async {
  try {
    final info = authService.userInfo;
    if (info == null) {
      print('AuthService: refreshLegacyCookies skipped - missing user info');
      return false;
    }
    final username = info.username;
    if (username.isEmpty) {
      print('AuthService: refreshLegacyCookies skipped - missing username');
      return false;
    }

    // Exchange for legacy token
    final tokenResp = await authService.httpService.get(
      ApiConstants.legacyTokenUrlForHref(),
    );
    final data = tokenResp.data ?? {};
    final code = (data['code'] ?? '').toString();
    final iv = (data['iv'] ?? '').toString();
    if (code.isEmpty || iv.isEmpty) {
      print('AuthService: Legacy token response missing code/iv');
      throw Exception('Legacy token response missing code/iv');
    }

    // Visit legacy site to set cookies (server will set cookies and redirect)
    final legacyUrl = '/$username/?token=$code&iv=$iv';
    // First hit without following redirects to capture initial Set-Cookie on 302
    final visitResp = await authService.httpService.getLegacy(
      legacyUrl,
    );

    // Success if we no longer see the loading placeholder
    final ok = !visitResp.data.contains('<div>Loading...</div>');
    if (!ok) {
      print('AuthService: Legacy visit may not have initialized cookies. Status: ${visitResp.statusCode}');
    }
    print('AuthService: Legacy cookies refreshed');
    return ok;
  } catch (e) {
    print('AuthService: refreshLegacyCookies exception: $e');
    return false;
  }
}
