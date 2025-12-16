import 'package:flutter/material.dart';
import '../../../../shared/constants/api_endpoints.dart';
import 'captcha_dialog.dart';
import '../../../../shared/views/custom_snackbar/snackbar_utils.dart';

/// Callback function signature for captcha state changes
typedef CaptchaStateCallback =
    void Function(bool isVerified, Object? captchaData);

/// Self-contained captcha input component that manages its own state
class CaptchaInput extends StatefulWidget {
  /// Callback function called when captcha verification state changes
  final CaptchaStateCallback? onCaptchaStateChanged;

  /// Optional initial verification state
  final bool initiallyVerified;

  /// Optional app ID for captcha service
  final String? appId;

  /// Optional business state for captcha context
  final String? bizState;

  /// Whether captcha input is enabled
  final bool enabled;

  const CaptchaInput({
    super.key,
    this.onCaptchaStateChanged,
    this.initiallyVerified = false,
    this.appId,
    this.bizState,
    this.enabled = true,
  });

  @override
  State<CaptchaInput> createState() => _CaptchaInputState();
}

class _CaptchaInputState extends State<CaptchaInput> {
  /// Internal state: whether captcha is verified
  bool _isCaptchaVerified = false;

  /// Internal state: captcha data from verification
  Object? _captchaData;

  /// Internal state: whether captcha verification is in progress
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _isCaptchaVerified = widget.initiallyVerified;
    _initializeTencentCaptchaDialog();
  }

  /// Initialize Tencent Captcha service
  void _initializeTencentCaptchaDialog() async {
    try {
      // Use provided appId or default for development
      final appId = widget.appId ?? API.tencentCaptchaAppId;
      TencentCaptchaDialog.init(appId);
      debugPrint(
        'CaptchaInput: Tencent Captcha initialized with appId: $appId',
      );
    } catch (e) {
      debugPrint('CaptchaInput: Error initializing Tencent Captcha: $e');
    }
  }

  /// Perform captcha verification
  void _performCaptchaVerification(Function(Object?)? onSuccess) async {
    if (_isVerifying) return; // Prevent multiple simultaneous verifications

    setState(() {
      _isVerifying = true;
    });

    debugPrint('CaptchaInput: Starting Tencent Captcha verification...');

    try {
      final config = TencentCaptchaDialogConfig(
        bizState: widget.bizState ?? '',
        enableDarkMode: Theme.of(context).brightness == Brightness.dark,
      );

      await TencentCaptchaDialog.verify(
        context: context,
        config: config,
        onLoaded: (dynamic data) {
          debugPrint('CaptchaInput: Captcha onLoaded: $data');
        },
        onSuccess: (dynamic data) {
          debugPrint('CaptchaInput: Captcha onSuccess: $data');
          setState(() {
            _isCaptchaVerified = true;
            _captchaData = data;
            _isVerifying = false;
          });

          // Notify parent of state change
          widget.onCaptchaStateChanged?.call(_isCaptchaVerified, _captchaData);
          onSuccess?.call(data);
        },
        onFail: (dynamic data) {
          debugPrint('CaptchaInput: Captcha onFail: $data');
          setState(() {
            _isCaptchaVerified = false;
            _captchaData = null;
            _isVerifying = false;
          });

          // Notify parent of state change
          widget.onCaptchaStateChanged?.call(_isCaptchaVerified, _captchaData);

          // Show failure feedback
          if (mounted) {
            SnackbarUtils.showError(
              context,
              'CaptchaInput: Captcha verification failed! Try again.',
            );
          }
        },
      );
    } catch (e) {
      debugPrint('CaptchaInput: Error during captcha verification: $e');
      setState(() {
        _isCaptchaVerified = false;
        _captchaData = null;
        _isVerifying = false;
      });

      // Notify parent of state change
      widget.onCaptchaStateChanged?.call(_isCaptchaVerified, _captchaData);

      // Show error feedback
      if (mounted) {
        SnackbarUtils.showError(context, 'CaptchaInput: Captcha error: $e');
      }
    }
  }

  /// Reset captcha verification state
  void resetVerification() {
    setState(() {
      _isCaptchaVerified = false;
      _captchaData = null;
      _isVerifying = false;
    });

    // Notify parent of state change
    widget.onCaptchaStateChanged?.call(_isCaptchaVerified, _captchaData);
  }

  /// Public getter for verification state (for external access if needed)
  bool get isVerified => _isCaptchaVerified;

  /// Public getter for captcha data (for external access if needed)
  Object? get captchaData => _captchaData;

  /// Manually trigger captcha verification (for fallback scenarios)
  void triggerManualVerification({Function(Object?)? onSuccess}) {
    _performCaptchaVerification(onSuccess);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 0, height: 0);
  }
}
