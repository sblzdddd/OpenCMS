import 'package:flutter/material.dart';
import '../../../services/services.dart';
import '../../shared/custom_snackbar/snackbar_utils.dart';

/// Component responsible for managing captcha verification and auto-solving
class CaptchaManager extends ChangeNotifier {
  bool _isCaptchaVerified = false;
  Object? _captchaData;

  bool get isCaptchaVerified => _isCaptchaVerified;
  Object? get captchaData => _captchaData;

  /// Handle captcha state changes from the CaptchaInput component
  void onCaptchaStateChanged(bool isVerified, Object? data) {
    _isCaptchaVerified = isVerified;
    _captchaData = data;
    notifyListeners();

    print('Captcha state changed - Verified: $isVerified, Data: ${data?.runtimeType}');
  }

  /// Reset captcha verification state
  void resetCaptcha() {
    _isCaptchaVerified = false;
    _captchaData = null;
    notifyListeners();
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
