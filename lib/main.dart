import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:opencms/features/auth/services/auth_service.dart';
import 'package:opencms/features/auth/services/login_state.dart';
import 'package:opencms/di/locator.dart';
import 'package:opencms/features/shared/pages/splash.dart';
import 'package:opencms/features/system/desktop_tray/tray_service.dart';
import 'package:opencms/features/system/desktop_window/window_service.dart';
import 'package:opencms/features/web_cms/services/webview_service.dart';
import 'package:opencms/utils/color_themes.dart';
import 'features/auth/views/pages/login.dart';
import 'features/home/views/pages/home.dart';
import 'package:window_manager/window_manager.dart';
import 'features/background/cookies_refresh_service.dart';
import 'features/theme/services/theme_services.dart';
import 'package:provider/provider.dart';
import 'features/system/update/update_checker_service.dart';
import 'package:logging/logging.dart';
import 'package:easy_logger/easy_logger.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  // Initialize logging
  Logger.root.level = kDebugMode ? Level.FINEST : Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.time} [${record.loggerName}] ${record.level.name}: ${record.message}');
  });
  EasyLocalization.logger.enableLevels = [LevelMessages.error, LevelMessages.warning, LevelMessages.info];

  configureDependencies();
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await WebviewService.initWebview();
  // init window manager and effects
  await OCMSWindowService.initWindowManager();
  await OCMSTrayService.initSystemTray();
  await CookiesRefreshService().start();
  // Initialize ThemeNotifier singleton
  await ThemeNotifier.initialize();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('zh', 'CN')],
      path: 'assets/langs',
      fallbackLocale: const Locale('en', 'US'),
      child: const OCMSApp(),
    ),
  );
}

class OCMSApp extends StatelessWidget {
  const OCMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: ThemeNotifier.instance)],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          Color seedColor = themeNotifier.currentColor;
          OCMSColorThemes colorThemes = OCMSColorThemes(context);

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: tr('app.title'),
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: colorThemes.buildLightTheme(seedColor),
            darkTheme: colorThemes.buildDarkTheme(seedColor),
            themeMode: themeNotifier.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const AuthWrapper(),
            routes: {
              '/login': (context) => const LoginPage(),
              '/home': (context) => const HomePage(),
            },
            navigatorObservers: [routeObserver],
            // preserve text dpi scale
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(1.0)),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => AuthWrapperState();
}

class AuthWrapperState extends State<AuthWrapper> with WindowListener {
  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _checkAuthenticationStatus();
    UpdateCheckerService.scheduleUpdateCheck(context);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Future<void> onWindowClose() async {
    await windowManager.hide();
  }

  void _checkAuthenticationStatus() async {
    await Future.delayed(const Duration(milliseconds: 100));
    await di<AuthService>().checkAuth();

    setState(() {
      _isAuthenticated = di<LoginState>().isAuthenticated;
      _isCheckingAuth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const SplashScreen();
    }
    return _isAuthenticated ? const HomePage() : const LoginPage();
  }
}
