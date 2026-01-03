import 'package:flutter/material.dart';
import 'package:opencms/di/locator.dart';
import '../../services/auto_captcha_service.dart';
import 'package:logging/logging.dart';

final logger = Logger('CaptchaManager');

/// Component responsible for managing captcha verification and auto-solving
class CaptchaManager extends ChangeNotifier {
  bool _isCaptchaVerified = false;
  Object? _captchaData;
  bool _isAutoSolving = false;

  bool get isCaptchaVerified => _isCaptchaVerified;
  Object? get captchaData => _captchaData;
  bool get isAutoSolving => _isAutoSolving;

  /// Handle captcha state changes from the CaptchaInput component
  void onCaptchaStateChanged(bool isVerified, Object? data) {
    _isCaptchaVerified = isVerified;
    _captchaData = data;
    notifyListeners();

    logger.fine(
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
  Future<bool> autoSolveCaptcha(String username) async {
    if (_isAutoSolving) return false;

    _isAutoSolving = true;
    notifyListeners();

    try {
      logger.fine('Attempting to auto-solve captcha');
      final captchaResult = await di<AutoCaptchaService>().getTicket(username);

      if (captchaResult != null) {
        _isCaptchaVerified = true;
        _captchaData = captchaResult;
        logger.fine(
          'Auto-solve successful, ticket: $captchaResult',
        );
        _isAutoSolving = false;
        notifyListeners();
        return true;
      } else {
        logger.fine('Auto-solve failed');
        _isAutoSolving = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      logger.severe('Auto-solve exception: $e');
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
