import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opencms/di/locator.dart';
import 'package:opencms/features/auth/services/auth_service.dart';
import 'package:opencms/features/auth/services/login_state.dart';
import 'package:opencms/features/shared/pages/splash.dart';
import 'package:window_manager/window_manager.dart';

import '../../../home/views/pages/home.dart';
import '../../../system/update/update_checker_service.dart';
import '../../services/credentials_storage_service.dart';
import '../components/captcha_input/captcha_input.dart';
import '../controllers/captcha_manager.dart';
import '../controllers/credentials_manager.dart';
import '../pages/login.dart';

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

    try {
      UpdateCheckerService.scheduleUpdateCheck(context);
    } catch (e) {
      // Ignore context errors during init
    }
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
      passwordController: TextEditingController(),
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
    final savedCred = await di<CredentialsStorageService>().loadCredentials();
    if (!savedCred.hasCredentials) {
      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
        });
      }
      return;
    }

    final username = savedCred.username;
    final password = savedCred.password;

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

  Future<void> _executeLogin(
    String username,
    String password,
    Object captchaData,
  ) async {
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
                di<CredentialsStorageService>().loadCredentials().then((cred) {
                  if (cred.hasCredentials) {
                    _executeLogin(cred.username, cred.password, data);
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
