import 'package:flutter/material.dart';
import '../../../api/constants.dart';
import 'captcha_dialog.dart';
import 'captcha_method_dialog.dart';
import '../../../api/captcha_solver/captcha_solver_exports.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Callback function signature for captcha state changes
typedef CaptchaStateCallback = void Function(bool isVerified, Object? captchaData);

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
  
  /// Current captcha verification method
  CaptchaVerificationMethod _method = CaptchaVerificationMethod.manual;
  
  /// Whether force auto-solve is enabled
  bool _forceAutoSolve = false;
  
  /// Check if we're in auto-solve mode (solvecaptcha method + force enabled)
  bool get _isAutoSolveMode => _method == CaptchaVerificationMethod.solveCaptcha && _forceAutoSolve;
  
  @override
  void initState() {
    super.initState();
    _isCaptchaVerified = widget.initiallyVerified;
    _initializeTencentCaptchaDialog();
    _loadMethod();
  }

  /// Initialize Tencent Captcha service
  void _initializeTencentCaptchaDialog() async {
    try {
      // Use provided appId or default for development
      final appId = widget.appId ?? ApiConstants.tencentCaptchaAppId;
      TencentCaptchaDialog.init(appId);
      print('Tencent Captcha initialized with appId: $appId');
    } catch (e) {
      print('Error initializing Tencent Captcha: $e');
    }
  }

  Future<void> _loadMethod() async {
    try {
      final settings = CaptchaSettingsService();
      final m = await settings.getMethod();
      final forceAutoSolve = await settings.getForceAutoSolve();
      if (mounted) {
        setState(() {
          _method = m;
          _forceAutoSolve = forceAutoSolve;
        });
      }
    } catch (_) {}
  }

  /// Perform captcha verification
  void _performCaptchaVerification(Function(Object?)? onSuccess) async {
    if (_isVerifying) return; // Prevent multiple simultaneous verifications
    
    setState(() {
      _isVerifying = true;
    });
    
    print('Starting Tencent Captcha verification...');
    
    try {
      final config = TencentCaptchaDialogConfig(
        bizState: widget.bizState ?? '',
        enableDarkMode: Theme.of(context).brightness == Brightness.dark,
      );

      await TencentCaptchaDialog.verify(
        context: context,
        config: config,
        onLoaded: (dynamic data) {
          print('Captcha onLoaded: $data');
        },
        onSuccess: (dynamic data) {
          print('Captcha onSuccess: $data');
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
          print('Captcha onFail: $data');
          setState(() {
            _isCaptchaVerified = false;
            _captchaData = null;
            _isVerifying = false;
          });
          
          // Notify parent of state change
          widget.onCaptchaStateChanged?.call(_isCaptchaVerified, _captchaData);
          
          // Show failure feedback
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Captcha verification failed! Try again.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
      );
    } catch (e) {
      print('Error during captcha verification: $e');
      setState(() {
        _isCaptchaVerified = false;
        _captchaData = null;
        _isVerifying = false;
      });
      
      // Notify parent of state change
      widget.onCaptchaStateChanged?.call(_isCaptchaVerified, _captchaData);
      
      // Show error feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Captcha error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
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
    
    // Reload method after reset
    _loadMethod();
    
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (_isVerifying || _isAutoSolveMode || !widget.enabled || _isCaptchaVerified) ? null : () => _performCaptchaVerification(null),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Checkbox(
                value: _isAutoSolveMode ? true : _isCaptchaVerified,
                fillColor: _isAutoSolveMode 
                  ? WidgetStateProperty.all(Colors.grey)
                  : (_isCaptchaVerified ? WidgetStateProperty.all(Colors.green) : WidgetStateProperty.all(Colors.transparent)),
                onChanged: null, // Disabled, controlled by captcha
              ),
              Expanded(
                child: Text(
                  _isAutoSolveMode
                    ? 'Auto-solved captcha'
                    : (_isVerifying
                        ? 'Verifying...'
                        : 'I am not a robot'),
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Captcha settings',
                icon: const Icon(Symbols.settings_rounded),
                onPressed: () async {
                  final saved = await CaptchaMethodDialog.show(context);
                  if (saved) {
                    await _loadMethod();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}