import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Captcha verification methods
enum CaptchaVerificationMethod {
  manual,
  solveCaptcha,
}

/// Service that persists captcha-related settings, such as user solvecaptcha API key
class CaptchaSettingsService {
  static final CaptchaSettingsService _instance = CaptchaSettingsService._internal();
  factory CaptchaSettingsService() => _instance;
  CaptchaSettingsService._internal();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _methodKey = 'captcha_method';
  static const String _solveCaptchaApiKeyKey = 'solvecaptcha_api_key';
  static const String _forceAutoSolveKey = 'force_auto_solve';

  Future<CaptchaVerificationMethod> getMethod() async {
    final value = await _storage.read(key: _methodKey);
    if (value == 'solveCaptcha') return CaptchaVerificationMethod.solveCaptcha;
    return CaptchaVerificationMethod.manual;
  }

  Future<void> setMethod(CaptchaVerificationMethod method) async {
    await _storage.write(
      key: _methodKey,
      value: method == CaptchaVerificationMethod.solveCaptcha ? 'solveCaptcha' : 'manual',
    );
  }

  Future<String?> getSolveCaptchaApiKey() async {
    return await _storage.read(key: _solveCaptchaApiKeyKey);
  }

  Future<void> setSolveCaptchaApiKey(String apiKey) async {
    await _storage.write(key: _solveCaptchaApiKeyKey, value: apiKey);
  }

  Future<bool> getForceAutoSolve() async {
    final value = await _storage.read(key: _forceAutoSolveKey);
    return value == 'true';
  }

  Future<void> setForceAutoSolve(bool forceAutoSolve) async {
    await _storage.write(key: _forceAutoSolveKey, value: forceAutoSolve.toString());
  }

  /// Get the effective captcha method for login (considering force auto-solve)
  Future<CaptchaVerificationMethod> getLoginMethod() async {
    final method = await getMethod();
    if (method == CaptchaVerificationMethod.solveCaptcha) {
      final forceAutoSolve = await getForceAutoSolve();
      return forceAutoSolve ? CaptchaVerificationMethod.solveCaptcha : CaptchaVerificationMethod.manual;
    }
    return method;
  }
}


