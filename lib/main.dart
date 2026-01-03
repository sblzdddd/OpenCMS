import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
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
import 'features/theme/services/theme_services.dart';
import 'package:provider/provider.dart';
import 'features/system/update/update_checker_service.dart';
import 'features/auth/views/controllers/credentials_manager.dart';
import 'features/auth/views/controllers/captcha_manager.dart';
import 'features/auth/views/components/captcha_input/captcha_input.dart';
import 'features/auth/services/credentials_storage_service.dart';
import 'package:logging/logging.dart';
import 'dart:async';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  // Initialize logging
  Logger.root.level = kDebugMode ? Level.FINEST : Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.time} [${record.loggerName}] ${record.level.name}: ${record.message}');
  });

  configureDependencies();
  WidgetsFlutterBinding.ensureInitialized();
  await WebviewService.initWebview();
  // init window manager and effects
  await OCMSWindowService.initWindowManager();
  await OCMSTrayService.initSystemTray();
  // Initialize ThemeNotifier singleton
  await ThemeNotifier.initialize();

  runApp(Phoenix(child: OCMSApp()));
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
            title: "OpenCMS",
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
  String? _statusText;

  // Managers for auto-login
  late final CredentialsManager _credentialsManager;
  late final CaptchaManager _captchaManager;
  final GlobalKey _captchaKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    
    _credentialsManager = CredentialsManager();
    _captchaManager = CaptchaManager();
    
    // Defer check to next frame to ensure managers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthenticationStatus();
    });
    
    UpdateCheckerService.scheduleUpdateCheck(context);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _credentialsManager.dispose();
    _captchaManager.dispose();
    super.dispose();
  }

  @override
  Future<void> onWindowClose() async {
    await windowManager.hide();
  }

  void _checkAuthenticationStatus() async {
    // Check existing session
    await di<AuthService>().checkAuth();
    final isSessionValid = di<LoginState>().isAuthenticated;

    if (isSessionValid) {
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
          _isCheckingAuth = false;
        });
      }
      return;
    }

    // If session invalid, check for auto-login
    await _credentialsManager.loadSavedCredentials(
      usernameController: TextEditingController(), 
      passwordController: TextEditingController()
    );

    if (_credentialsManager.autoLogin && _credentialsManager.rememberMe) {
        await _performAutoLogin();
    } else {
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isCheckingAuth = false;
        });
      }
    }
  }

  Future<void> _performAutoLogin() async {
    if (!mounted) return;
    
    // Get credentials from storage (already loaded in manager but we need the values)
    final savedCreds = await di<CredentialsStorageService>().loadCredentials();
    if (!savedCreds.hasCredentials) {
      setState(() { _isCheckingAuth = false; });
      return;
    }

    final username = savedCreds.username;
    final password = savedCreds.password;

    setState(() {
      _statusText = 'Logging in as $username...';
    });
    
    // a. Try auto-solve captcha
    bool captchaVerified = await _captchaManager.autoSolveCaptcha(username);
    if (captchaVerified) {
      await _executeLogin(username, password, _captchaManager.captchaData!);
      return;
    }

    // b. If auto-solve failed, trigger manual verification
    if (!mounted) return;

    // Wait for manual verification
    final completer = Completer<bool>();
    
    _captchaManager.triggerManualVerification(
      _captchaKey,
      onSuccess: (data) {
        if (!completer.isCompleted) completer.complete(true);
      },
    );
  }

  Future<void> _executeLogin(String username, String password, Object captchaData) async {
     final success = await di<AuthService>().login(
        username: username,
        password: password,
        captchaData: captchaData,
      );

      if (mounted) {
        if (success.isSuccess) {
           setState(() {
            _isAuthenticated = true;
            _isCheckingAuth = false;
          });
        } else {
           // Login failed, fallback to login page
           setState(() {
            _isAuthenticated = false;
            _isCheckingAuth = false;
            _statusText = null;
          });
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return Stack(
        children: [
          // Splash Screen with optional status text
          SplashScreen(statusText: _statusText), 
          
          // Invisible Captcha Input for manual verification fallback
          CaptchaInput(
            key: _captchaKey,
            onCaptchaStateChanged: (verified, data) {
               if (verified && data != null && _credentialsManager.autoLogin) {
                  di<CredentialsStorageService>().loadCredentials().then((creds) {
                    if (creds.hasCredentials) {
                       _executeLogin(creds.username, creds.password, data);
                    }
                  });
               }
            },
          ),
        ],
      );
    }
    return _isAuthenticated ? const HomePage() : const LoginPage();
  }
}

