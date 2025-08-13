import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'api/api.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/foundation.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

WebViewEnvironment? webViewEnvironment;

// Export webViewEnvironment for access from other files
WebViewEnvironment? getWebViewEnvironment() => webViewEnvironment;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initInAppWebview();
  runApp(const MyApp());
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenCMS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 99, 0, 0),
          primary: const Color.fromARGB(255, 99, 0, 0),
          secondary: const Color.fromARGB(255, 51, 153, 153),
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  void _checkAuthenticationStatus() async {
    // Add a small delay to show loading state
    await Future.delayed(const Duration(milliseconds: 500));

    // Try restore session from saved cookies by validating against account/user
    final restored = await _authService.restoreSessionFromCookies();

    setState(() {
      _isAuthenticated = restored || (_authService.isAuthenticated && _authService.isSessionValid());
      _isCheckingAuth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FF),
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


