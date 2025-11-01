import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:opencms/pages/splash.dart';
import 'package:opencms/services/system/desktop_tray/tray_service.dart';
import 'package:opencms/services/system/desktop_window/window_service.dart';
import 'package:opencms/services/system/webview/webview_service.dart';
import 'package:opencms/utils/color_themes.dart';
import 'pages/login.dart';
import 'pages/home.dart';
import 'services/services.dart';
import 'package:window_manager/window_manager.dart';
import 'services/background/cookies_refresh_service.dart';
import 'services/theme/theme_services.dart';
import 'package:provider/provider.dart';
import 'services/system/update/update_checker_service.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
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
  final AuthService _authService = AuthService();
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
    await Future.delayed(const Duration(milliseconds: 500));

    bool isAuthenticated = false;
    await _authService.refreshCookies();

    try {
      await _authService.fetchAndSetCurrentUserInfo();
      await _authService.refreshLegacyCookies();
      isAuthenticated = true;
    } catch (e) {
      isAuthenticated = false;
    }

    setState(() {
      _isAuthenticated = isAuthenticated;
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
