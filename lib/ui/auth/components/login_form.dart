import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../../../services/theme/theme_services.dart';
import '../../shared/widgets/skin_icon_widget.dart';
import 'captcha_input/captcha_input.dart';
import 'password_input.dart';
import 'username_input.dart';
import '../controllers/login_form_controller.dart';
import '../../../pages/settings/privacy_policy_page.dart';
import 'package:flutter/gestures.dart';
import '../../shared/custom_snackbar/snackbar_utils.dart';

class LoginForm extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;
  final GlobalKey captchaKey;

  const LoginForm({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.formKey,
    required this.captchaKey,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late final LoginFormController _controller;
  bool _agreedToPrivacyPolicy = false;

  @override
  void initState() {
    super.initState();
    _controller = LoginFormController();
    _controller.initialize();

    // Load saved credentials
    _controller.loadSavedCredentials(
      usernameController: widget.usernameController,
      passwordController: widget.passwordController,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Clear all form data and state
  void _clearForm() {
    _controller.clearForm(
      context,
      usernameController: widget.usernameController,
      passwordController: widget.passwordController,
      captchaKey: widget.captchaKey,
    );
  }

  /// Perform the complete login flow
  Future<void> _performLogin() async {
    if (!_agreedToPrivacyPolicy) {
      SnackbarUtils.showError(context, 'Please agree to the Privacy Policy & Legal Terms');
      return;
    }
    await _controller.performLogin(
      context,
      formKey: widget.formKey,
      usernameController: widget.usernameController,
      passwordController: widget.passwordController,
      captchaKey: widget.captchaKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final isLoading = _controller.isLoading;
        final isLoadingCredentials = _controller.isLoadingCredentials;

        return Stack(
          children: [
            Form(
              key: widget.formKey,
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 14),
                      SkinIcon(
                        imageKey: 'global.app_icon',
                        fallbackIcon: Symbols.school_rounded,
                        size: 80,
                        iconSize: 80,
                        fallbackIconColor: Theme.of(context).colorScheme.primary,
                        fallbackIconBackgroundColor: Colors.transparent,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Login with your'
                        ' SC'
                        'IE'
                        ' Account',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 26),

                      // Username field
                      UsernameInput(
                        controller: widget.usernameController,
                        labelText: 'Username',
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      PasswordInput(
                        controller: widget.passwordController,
                        labelText: 'Password',
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Captcha field
                      CaptchaInput(
                        key: widget.captchaKey,
                        onCaptchaStateChanged:
                            _controller.captchaManager.onCaptchaStateChanged,
                        initiallyVerified:
                            _controller.captchaManager.isCaptchaVerified,
                        enabled: !isLoading,
                      ),

                      // Remember me checkbox
                      CheckboxListTile(
                        title: Text(
                          'Remember my credentials',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          'Securely save credentials for next login',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(153),
                            fontSize: 12,
                          ),
                        ),
                        value: _controller.credentialsManager.rememberMe,
                        onChanged: isLoading
                            ? null
                            : (value) {
                                _controller.credentialsManager.rememberMe =
                                    value ?? false;
                              },
                        activeColor: Theme.of(context).colorScheme.primary,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                        ),
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      // Privacy Policy agreement checkbox
                      CheckboxListTile(
                        title: Row(
                          children: [
                            Flexible(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'I agree to the ',
                                    ),
                                    TextSpan(
                                      text: 'Privacy Policy & Legal Terms',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => const PrivacyPolicyPage(),
                                            ),
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        value: _agreedToPrivacyPolicy,
                        onChanged: isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _agreedToPrivacyPolicy = value ?? false;
                                });
                              },
                        activeColor: Theme.of(context).colorScheme.primary,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 16),

                      // Login button
                      ElevatedButton(
                        onPressed: (isLoading || isLoadingCredentials)
                            ? null
                            : _performLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: themeNotifier.getBorderRadiusAll(0.75),
                          ),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                        child: (isLoading || isLoadingCredentials)
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Login',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Material(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          shape: const CircleBorder(),
                          child: IconButton(
                            tooltip: 'Clear form',
                            icon: const Icon(Symbols.delete_sweep_rounded),
                            onPressed: isLoading ? null : _clearForm,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Material(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          shape: const CircleBorder(),
                          child: IconButton(
                            tooltip: themeNotifier.isDarkMode ? 'Switch to light theme' : 'Switch to dark theme',
                            icon: Icon(
                              themeNotifier.isDarkMode 
                                ? Symbols.light_mode_rounded 
                                : Symbols.dark_mode_rounded,
                            ),
                            onPressed: isLoading ? null : () => themeNotifier.toggleTheme(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
