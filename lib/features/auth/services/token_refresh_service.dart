import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:opencms/features/shared/constants/api_endpoints.dart';
import 'package:opencms/features/auth/services/login_state.dart';
import 'package:opencms/features/auth/models/auth_models.dart';
import 'package:opencms/di/locator.dart';
import 'package:opencms/features/API/networking/http_service.dart';
import 'package:opencms/features/API/storage/token_storage.dart';

final log = Logger('TokenRefreshService');

class TokenRefreshService {
  final TokenStorage storage;
  TokenRefreshService._(this.storage);

  factory TokenRefreshService() {
    return TokenRefreshService._(TokenStorage());
  }

  static Future<bool>? _refreshNewTokenInFlight;
  static Future<bool>? _refreshLegacyCookiesInFlight;

  Future<bool> refreshNewToken({bool skipAuth = false}) async {
    // If a refresh is already in flight, await the same future.
    final inFlight = _refreshNewTokenInFlight;
    if (inFlight != null) return await inFlight;

    final future = _doRefreshNewToken(skipAuth: skipAuth);
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

  Future<bool> _doRefreshNewToken({bool skipAuth = false}) async {
    try {
      final refreshToken = await storage.refreshToken;
      if (refreshToken == null || refreshToken.isEmpty) return false;

      log.info('Refreshing access token using refresh token.');

      final resp = await di<HttpService>().post(
        API.tokenRefreshUrl,
        data: {'refresh': refreshToken},
      );
      if(!di<LoginState>().isAuthenticated && !skipAuth) return false;
      if (resp.statusCode == 200) {
        final data = TokenResponse.fromJson(resp.data);
        if (data.accessToken != null && data.accessToken?.isNotEmpty == true) {
          await storage.setAccessToken('Bearer ${data.accessToken}');
        }
        if (data.refreshToken != null && data.refreshToken?.isNotEmpty == true) {
          await storage.setRefreshToken(data.refreshToken);
        }
        log.info('Token refresh successful.');
        log.fine('Refreshed access token: ${data.accessToken}, refresh token: ${data.refreshToken}');
        return true;
      } else {
        log.warning('Token refresh failed with status: ${resp.statusCode}');
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
        options: Options(extra: {"legacyRefresh": true}),
      );
      final data = LegacyTokenResponse.fromJson(tokenResp.data);

      if (data.code.isEmpty || data.iv.isEmpty) {
        log.warning('Response missing code/iv');
        return false;
      }

      // Visit legacy site to set cookies (server will set cookies and redirect)
      final result = await di<HttpService>().get(
        '/?token=${data.code}&iv=${data.iv}',
        refresh: true,
        legacy: true,
        options: Options(extra: {"legacyRefresh": true}),
      );

      final List<String>? cookies = result.headers[HttpHeaders.setCookieHeader];
      if(cookies == null || cookies.isEmpty) {
        log.warning('No Set-Cookie headers received from legacy site.');
        return false;
      }
      int flag = 0;
      for(final cookie in cookies) {
        logger.fine(cookie);
        if(cookie.startsWith('sid_nb=')) {
          await storage.setSidNb(cookie.substring(7).split(';').first);
          flag++;
        }
        if(cookie.startsWith('sid_scie=')) {
          await storage.setSidScie(cookie.substring(9).split(';').first);
          flag++;
        }
      }
      if(flag < 2){
        log.warning('Not enough credentials obtained');
        return false;
      }
      log.info('Legacy cookies refreshed');
      return true;
    } catch (e) {
      log.severe('refreshLegacyCookies exception: $e');
      return false;
    }
  }
}
