import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'services/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/foundation.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'dart:io';
import 'services/background/cookies_refresh_service.dart';
import 'services/theme/theme_services.dart';
import 'package:provider/provider.dart';
import 'utils/text_theme_util.dart';
import 'utils/global_press_scale.dart';
import 'ui/shared/widgets/custom_app_bar.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'services/update/update_checker.dart';
import 'ui/shared/widgets/skin_icon_widget.dart';
import 'utils/app_info.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

WebViewEnvironment? webViewEnvironment;
WindowManager? globalAppWindow; // Global variable to store window manager instance
AuthWrapperState? globalAuthWrapper; // Global variable to access auth wrapper


// Function to handle window close event - hide instead of close
Future<void> handleWindowClose() async {
  if (globalAppWindow != null) {
    await globalAppWindow!.hide();
  } else {
    debugPrint('Main: globalAppWindow is null');
  }
}

Future<void> initInAppWebview() async {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    final availableVersion = await WebViewEnvironment.getAvailableVersion();
    assert(availableVersion != null,
        'Failed to find an installed WebView2 Runtime or non-stable Microsoft Edge installation.');
    webViewEnvironment = await WebViewEnvironment.create();
  }

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }
  PlatformInAppWebViewController.debugLoggingSettings.enabled = false;
}

Future<void> initWindowManager() async {
  // Return early if not Windows environment
  if (kIsWeb || !Platform.isWindows) {
    return;
  }
  
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    minimumSize: Size(400, 400),
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Prevent the default close behavior and handle it manually
  await windowManager.setPreventClose(true);
}

Future<void> initSystemTray() async {
  if(!(Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    return;
  }
  
  String path = 'assets/icon/app_icon.ico';
  globalAppWindow = windowManager; // Store globally for access from other functions

  // Initialize tray_manager
  await trayManager.destroy(); // Clear any existing tray
  await trayManager.setIcon(path);
  await trayManager.setToolTip('OpenCMS');
  
  // Create context menu
  final menu = Menu(
    items: [
      MenuItem(
        key: 'show_window',
        label: 'Show',
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'exit_app',
        label: 'Exit',
      ),
    ],
  );
  
  // Set the context menu
  await trayManager.setContextMenu(menu);

  // Add tray listener to handle events
  trayManager.addListener(_TrayListener());
}

class _TrayListener with TrayListener {
  @override
  void onTrayIconMouseDown() {
    if (Platform.isWindows) {
      windowManager.show();
    } else {
      trayManager.popUpContextMenu();
    }
  }

  @override
  void onTrayIconRightMouseDown() {
    if (Platform.isWindows) {
      trayManager.popUpContextMenu();
    } else {
      windowManager.show();
    }
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'show_window':
        windowManager.show();
        break;
      case 'exit_app':
        await windowManager.setPreventClose(false);
        await windowManager.close();
        break;
    }
  }
}

Future<void> initFlutterAcrylic() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await Window.initialize();
  }
}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFlutterAcrylic();
  await initInAppWebview();
  await initWindowManager();
  await initSystemTray();
  await CookiesRefreshService().start();
  
  // Initialize ThemeNotifier singleton
  await ThemeNotifier.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Roboto", "EB Garamond");
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ThemeNotifier.instance),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          Color seedColor = themeNotifier.currentColor;
          ColorScheme lightColorScheme = ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.light,
          );
          ColorScheme darkColorScheme = ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.dark,
          );
          return MaterialApp(
            title: 'OpenCMS',
            theme: ThemeData(
              colorScheme: lightColorScheme,
              textTheme: textTheme.apply(
                bodyColor: lightColorScheme.onSurface,
                displayColor: lightColorScheme.onSurface,
              ),
              extensions: <ThemeExtension<dynamic>>[
                const AppInteractionTheme(scaleDownFactor: 0.9),
              ],
            ),
            darkTheme: ThemeData(
              colorScheme: darkColorScheme,
              textTheme: textTheme.apply(
                bodyColor: darkColorScheme.onSurface,
                displayColor: darkColorScheme.onSurface,
              ),
              extensions: <ThemeExtension<dynamic>>[
                const AppInteractionTheme(scaleDownFactor: 0.9),
              ],
            ),
            themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AuthWrapper(),
            routes: {
              '/login': (context) => const LoginPage(),
              '/home': (context) => const HomePage(),
            },
            navigatorObservers: [routeObserver],
            builder: (context, child) {
              return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
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
  String _versionInfoText = '';
  String _deviceInfoText = '';

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    
    // Set global reference for access from other parts of the app
    globalAuthWrapper = this;
    
    _checkAuthenticationStatus();
    _initVersionAndDeviceInfo();

    // Non-blocking update check after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        UpdateChecker.checkForUpdates(context);
      }
    });
  }

  Future<void> _initVersionAndDeviceInfo() async {
    try {
      final String versionText = await AppInfoUtil.getVersionText();
      final String deviceText = await AppInfoUtil.getDeviceText();
      if (!mounted) return;
      setState(() {
        _versionInfoText = versionText;
        _deviceInfoText = deviceText;
      });
    } catch (_) {
      // No-op on failure; footer will simply be hidden
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    
    // Clear global reference
    if (globalAuthWrapper == this) {
      globalAuthWrapper = null;
    }

    super.dispose();
  }

  @override
  Future<void> onWindowClose() async {
    // Hide instead of closing
    await handleWindowClose();
  }

  void _checkAuthenticationStatus() async {
    // Add a small delay to show loading state
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
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkinIcon(
                imageKey: 'global.app_icon',
                fallbackIcon: Symbols.school_rounded,
                fallbackIconColor: Theme.of(context).colorScheme.primary,
                fallbackIconBackgroundColor: Colors.transparent,
                size: 96,
                iconSize: 72,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
        
        appBar: PreferredSize(
          preferredSize: const Size(double.maxFinite, 50),
          child: CustomAppBar(),
        ),
        bottomNavigationBar: (_versionInfoText.isNotEmpty || _deviceInfoText.isNotEmpty)
            ? SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    [
                      if (_versionInfoText.isNotEmpty) _versionInfoText,
                      if (_deviceInfoText.isNotEmpty) _deviceInfoText,
                    ].join(' • '),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              )
            : null,
      );
    }

    return _isAuthenticated ? const HomePage() : const LoginPage();
  }
}


