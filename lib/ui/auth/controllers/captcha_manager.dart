import 'package:flutter/material.dart';
import '../../../services/auth/functions/auto_captcha_functions.dart';
import '../../../services/auth/auth_service_base.dart';

/// Component responsible for managing captcha verification and auto-solving
class CaptchaManager extends ChangeNotifier {
  bool _isCaptchaVerified = false;
  Object? _captchaData;
  bool _isAutoSolving = false;
  final AuthServiceBase _authService = AuthServiceBase();

  bool get isCaptchaVerified => _isCaptchaVerified;
  Object? get captchaData => _captchaData;
  bool get isAutoSolving => _isAutoSolving;

  /// Handle captcha state changes from the CaptchaInput component
  void onCaptchaStateChanged(bool isVerified, Object? data) {
    _isCaptchaVerified = isVerified;
    _captchaData = data;
    notifyListeners();

    debugPrint(
      'Captcha state changed - Verified: $isVerified, Data: ${data?.runtimeType}',
    );
  }

  /// Reset captcha verification state
  void resetCaptcha() {
    _isCaptchaVerified = false;
    _captchaData = null;
    notifyListeners();
  }

  /// Automatically solve captcha using the auto captcha service
  Future<bool> autoSolveCaptcha() async {
    if (_isAutoSolving) return false;

    _isAutoSolving = true;
    notifyListeners();

    try {
      debugPrint('CaptchaManager: Attempting to auto-solve captcha');
      final captchaResult = await getTicket(_authService);

      if (captchaResult != false) {
        _isCaptchaVerified = true;
        _captchaData = captchaResult;
        debugPrint(
          'CaptchaManager: Auto-solve successful, ticket: $captchaResult',
        );
        _isAutoSolving = false;
        notifyListeners();
        return true;
      } else {
        debugPrint('CaptchaManager: Auto-solve failed');
        _isAutoSolving = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('CaptchaManager: Auto-solve exception: $e');
      _isAutoSolving = false;
      notifyListeners();
      return false;
    }
  }

  /// Trigger manual captcha verification
  void triggerManualVerification(
    GlobalKey captchaKey, {
    Function(Object?)? onSuccess,
  }) {
    (captchaKey.currentState as dynamic)?.triggerManualVerification(
      onSuccess: (data) {
        _isCaptchaVerified = true;
        _captchaData = data;
        notifyListeners();
        onSuccess?.call(data);
      },
    );
  }

  /// Reset captcha UI component
  void resetCaptchaUI(GlobalKey captchaKey) {
    (captchaKey.currentState as dynamic)?.resetVerification();
  }
}
