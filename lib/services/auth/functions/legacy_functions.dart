import '../../../data/constants/api_constants.dart';
import '../auth_service_base.dart';

/// Acquire legacy (old CMS) cookies by exchanging a legacy token and visiting legacy site.
/// Returns true on success, false otherwise.
Future<bool> ensureLegacyCookies(AuthServiceBase authService) async {
  try {
    final info = authService.userInfo ?? {};
    final username = (info['username'] ?? '').toString();
    if (username.isEmpty) {
      print('AuthService: ensureLegacyCookies skipped - missing username');
      return false;
    }

    // Exchange for legacy token
    final tokenResp = await authService.httpService.get(
      ApiConstants.legacyTokenUrlForHref(),
      headers: {
        'referer': ApiConstants.cmsReferer,
      },
    );
    if (!tokenResp.isSuccess) {
      print('AuthService: Legacy token request failed: ${tokenResp.statusCode}');
      return false;
    }
    final data = tokenResp.jsonBody ?? {};
    final code = (data['code'] ?? '').toString();
    final iv = (data['iv'] ?? '').toString();
    if (code.isEmpty || iv.isEmpty) {
      print('AuthService: Legacy token response missing code/iv');
      return false;
    }

    // Visit legacy site to set cookies (server will set cookies and redirect)
    final legacyUrl = '${ApiConstants.legacyUserBaseUrl(username)}/?token=$code&iv=$iv';
    // First hit without following redirects to capture initial Set-Cookie on 302
    final visitResp = await authService.httpService.getRaw(
      legacyUrl,
      headers: {
        'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'referer': ApiConstants.cmsReferer,
      },
      followRedirects: false,
    );

    // Success if we no longer see the loading placeholder
    final ok = visitResp.isSuccess && !visitResp.body.contains('<div>Loading...</div>');
    if (!ok) {
      print('AuthService: Legacy visit may not have initialized cookies. Status: ${visitResp.statusCode}');
    }
    return ok;
  } catch (e) {
    print('AuthService: ensureLegacyCookies exception: $e');
    return false;
  }
}
