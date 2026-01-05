import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../../theme/services/theme_services.dart';
import '../../../theme/views/widgets/skin_icon_widget.dart';
import 'captcha_input/captcha_input.dart';
import 'password_input.dart';
import 'username_input.dart';
import '../controllers/login_form_controller.dart';
import '../../../settings/privacy_policy.dart';
import 'package:flutter/gestures.dart';

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
                      Center(
                        child: SkinIcon(
                          imageKey: 'global.app_icon',
                          fallbackIcon: Symbols.school_rounded,
                          size: 80,
                          iconSize: 80,
                          fallbackIconColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          fallbackIconBackgroundColor: Colors.transparent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          'Login with your Account',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
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
                      const SizedBox(height: 4),

                      // Captcha field
                      CaptchaInput(
                        key: widget.captchaKey,
                        onCaptchaStateChanged:
                            _controller.captchaManager.onCaptchaStateChanged,
                        initiallyVerified:
                            _controller.captchaManager.isCaptchaVerified,
                        enabled: !isLoading,
                        usernameController: widget.usernameController,
                      ),
                      const SizedBox(height: 8),
                      
                      // Remember me checkbox
                      CheckboxListTile(
                        title: Text(
                          'Remember my credentials',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
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
                      CheckboxListTile(
                        title: Text(
                          'Auto-login next time',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                          ),
                        ),
                        value: _controller.credentialsManager.autoLogin,
                        onChanged: isLoading
                            ? null
                            : (value) {
                                _controller.credentialsManager.autoLogin =
                                    value ?? false;
                              },
                        activeColor: Theme.of(context).colorScheme.primary,
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 8),

                      // Login button
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: (isLoading || isLoadingCredentials)
                                ? null
                                : _performLogin,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: themeNotifier.getBorderRadiusAll(
                                  0.75,
                                ),
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
                                : Text('Login'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Privacy Policy & Legal Terms',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(100),
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
                            tooltip: themeNotifier.isDarkMode
                                ? 'Switch to light theme'
                                : 'Switch to dark theme',
                            icon: Icon(
                              themeNotifier.isDarkMode
                                  ? Symbols.light_mode_rounded
                                  : Symbols.dark_mode_rounded,
                            ),
                            onPressed: isLoading
                                ? null
                                : () => themeNotifier.toggleTheme(),
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
