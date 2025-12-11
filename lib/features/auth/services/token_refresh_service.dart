import 'package:logging/logging.dart';
import 'package:opencms/features/auth/login_state.dart';
import 'package:opencms/features/auth/models/auth_models.dart';
import 'package:opencms/features/core/di/locator.dart';
import 'package:opencms/features/core/storage/token_storage.dart';
import 'package:opencms/services/services.dart';

final log = Logger('TokenRefreshService');

class TokenRefreshService {
  final TokenStorage storage;
  TokenRefreshService._(this.storage);

  factory TokenRefreshService() {
    return TokenRefreshService._(TokenStorage());
  }

  static Future<bool>? _refreshNewTokenInFlight;
  static Future<bool>? _refreshLegacyCookiesInFlight;

  Future<bool> refreshNewToken() async {
    // If a refresh is already in flight, await the same future.
    final inFlight = _refreshNewTokenInFlight;
    if (inFlight != null) return await inFlight;

    final future = _doRefreshNewToken();
    _refreshNewTokenInFlight = future;
    try {
      return await future;
    } finally {
      // Reset so future calls can start a new attempt
      if (identical(_refreshNewTokenInFlight, future)) {
        _refreshNewTokenInFlight = null;
      }
    }
  }

  Future<bool> _doRefreshNewToken() async {
    try {
      final refreshToken = await storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      log.info('Refreshing access token using refresh token.');

      final resp = await di<HttpService>().post(
        API.tokenRefreshUrl,
        data: {'refresh': refreshToken},
      );
      if(!di<LoginState>().isAuthenticated) return false;
      if (resp.statusCode == 200) {
        final data = TokenResponse.fromJson(resp.data);
        await storage.setAccessToken('Bearer ${data.accessToken}');
        await storage.setRefreshToken(data.refreshToken);
        log.info('Token refresh successful.');
        log.fine('Refreshed access token: ${data.accessToken}, refresh token: ${data.refreshToken}');
        return true;
      }
      return false;
    } catch (e) {
      log.severe('Error refreshing token: $e');
      return false;
    }
  }

  Future<bool> refreshLegacyCookies() async {
    // If a refresh is already in flight, await the same future.
    final inFlight = _refreshLegacyCookiesInFlight;
    if (inFlight != null) return await inFlight;

    final future = _doRefreshLegacyCookies();
    _refreshLegacyCookiesInFlight = future;
    try {
      return await future;
    } finally {
      if (identical(_refreshLegacyCookiesInFlight, future)) {
        _refreshLegacyCookiesInFlight = null;
      }
    }
  }

  Future<bool> _doRefreshLegacyCookies() async {
    try {
      if (di<LoginState>().isAuthenticated == false) {
        log.warning('Cannot refresh: user not authenticated.');
        return false;
      }
      final userInfo = di<LoginState>().userInfo;
      if (userInfo == null) {
        log.warning('Cannot refresh: no user info available.');
        return false;
      }

      // Exchange for legacy token
      final tokenResp = await di<HttpService>().get(
        API.legacyTokenUrlForHref,
        refresh: true,
      );
      final data = LegacyTokenResponse.fromJson(tokenResp.data);

      if (data.code.isEmpty || data.iv.isEmpty) {
        log.warning('Response missing code/iv');
        return false;
      }

      // Visit legacy site to set cookies (server will set cookies and redirect)
      final result = await di<HttpService>().get(
        '/${userInfo.userName}/?token=${data.code}&iv=${data.iv}',
        refresh: true,
        legacy: true,
      );

      // Success if we no longer see the loading placeholder
      final ok = !result.data.contains('<div>Loading...</div>');
      if (!ok) {
        log.warning('Legacy visit may not have initialized cookies. Status: ${result.statusCode}');
      }
      log.info('Legacy cookies refreshed');
      return ok;
    } catch (e) {
      log.severe('refreshLegacyCookies exception: $e');
      return false;
    }
  }
}
