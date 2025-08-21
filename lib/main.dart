import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'services/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/foundation.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:window_manager/window_manager.dart';
import 'package:system_tray/system_tray.dart';
import 'dart:io';
import 'services/background/cookies_refresh_service.dart';
import 'services/theme/theme_services.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'util.dart';
// import 'services/background/background_task_manager.dart';

final InAppLocalhostServer localhostServer = InAppLocalhostServer(documentRoot: 'assets');
WebViewEnvironment? webViewEnvironment;
AppWindow? globalAppWindow; // Global variable to store AppWindow instance
_AuthWrapperState? globalAuthWrapper; // Global variable to access auth wrapper


// Function to handle window close event - hide instead of close
Future<void> handleWindowClose() async {
  if (globalAppWindow != null) {
    await globalAppWindow!.hide();
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
}

Future<void> initWindowManager() async {
  // Return early if not Windows environment
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.windows) {
    return;
  }
  
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(1000, 720),
    minimumSize: Size(400, 400),
    titleBarStyle: TitleBarStyle.normal,
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
  String path = Platform.isWindows ? 'assets/images/app_icon.ico' : 'assets/images/app_icon.png';

  final AppWindow appWindow = AppWindow();
  globalAppWindow = appWindow; // Store globally for access from other functions
  final SystemTray systemTray = SystemTray();

  await systemTray.initSystemTray(
    title: "OpenCMS",
    iconPath: path,
  );

  // create context menu
  final Menu menu = Menu();
  await menu.buildFrom([
    MenuItemLabel(label: 'Show', onClicked: (menuItem) => appWindow.show()),
    MenuItemLabel(label: 'Exit', onClicked: (menuItem) async {
      // Allow closing then exit
      await windowManager.setPreventClose(false);
      await appWindow.close();
    }),
  ]);

  // set context menu
  await systemTray.setContextMenu(menu);

  // handle system tray event
  systemTray.registerSystemTrayEventHandler((eventName) {
    if (eventName == kSystemTrayEventClick) {
       Platform.isWindows ? appWindow.show() : systemTray.popUpContextMenu();
    } else if (eventName == kSystemTrayEventRightClick) {
       Platform.isWindows ? systemTray.popUpContextMenu() : appWindow.show();
    }
  });
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initInAppWebview();
  await initWindowManager();
  await initSystemTray();
  // await Workmanager().initialize(_callbackDispatcher, isInDebugMode: true);
  await CookiesRefreshService().start();
  
  // await Workmanager().registerOneOffTask(
  //   "ping_test", // unique ID
  //   "ping_test", // task name
  //   initialDelay: const Duration(seconds: 10),
  // );
  // // Periodic task with custom frequency  
  // Workmanager().registerPeriodicTask(
  //   "hourly-sync",
  //   "data_sync",
  //   frequency: Duration(hours: 1),        // Android: minimum 15 minutes
  //   initialDelay: Duration(seconds: 10),   // Wait before first execution
  //   inputData: {'syncType': 'incremental'}
  // );
  await localhostServer.start();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Roboto", "EB Garamond");
    MaterialTheme theme = MaterialTheme(textTheme);
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            title: 'OpenCMS',
            theme: theme.light(),
            darkTheme: theme.dark(),
            themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AuthWrapper(),
            routes: {
              '/login': (context) => const LoginPage(),
              '/home': (context) => const HomePage(),
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
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WindowListener {
  final AuthService _authService = AuthService();
  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    
    // Set global reference for access from other parts of the app
    globalAuthWrapper = this;
    
    _checkAuthenticationStatus();
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
              Icon(
                Symbols.school_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading OpenCMS...',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _isAuthenticated ? const HomePage() : const LoginPage();
  }
}


