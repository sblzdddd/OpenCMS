import 'package:opencms/features/auth/services/token_refresh_service.dart';
import 'package:opencms/di/locator.dart';

import 'background_fetcher.dart';
import 'package:flutter/foundation.dart';

class CookiesRefreshService extends BackgroundFetcher {
  static final CookiesRefreshService _instance =
      CookiesRefreshService._internal();
  factory CookiesRefreshService() => _instance;
  CookiesRefreshService._internal()
    : super(
        name: "cookiesRefresh",
        taskId: "cookiesRefresh",
        interval: const Duration(minutes: 10),
        storageKey: "cookiesRefresh",
      );

  @override
  Future<void> start() async {
    await super.start();
    debugPrint('CookiesRefreshService started');
  }

  @override
  Future<void> onUpdate() async {
    await di<TokenRefreshService>().refreshNewToken();
    await di<TokenRefreshService>().refreshLegacyCookies();
  }
}
