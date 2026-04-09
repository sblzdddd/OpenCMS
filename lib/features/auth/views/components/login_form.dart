import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/features/auth/views/controllers/login_form_controller.dart';
import 'package:opencms/features/theme/services/theme_services.dart';
import 'package:opencms/features/theme/views/widgets/skin_icon_widget.dart';

import 'captcha_input/captcha_input.dart';
import 'password_input.dart';
import 'username_input.dart';

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
    final themeNotifier = ThemeNotifier.instance;
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
                      const SizedBox(height: 8),
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
                      const SizedBox(height: 12),

                      // Keep me signed in checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value:
                                  _controller.credentialsManager.rememberMe ||
                                  _controller.credentialsManager.autoLogin,
                              onChanged: isLoading
                                  ? null
                                  : (value) {
                                      final isChecked = value ?? false;
                                      _controller
                                              .credentialsManager
                                              .rememberMe =
                                          isChecked;
                                      _controller.credentialsManager.autoLogin =
                                          isChecked;
                                    },
                              activeColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: isLoading
                                ? null
                                : () {
                                    final newValue =
                                        !(_controller
                                                .credentialsManager
                                                .rememberMe ||
                                            _controller
                                                .credentialsManager
                                                .autoLogin);
                                    _controller.credentialsManager.rememberMe =
                                        newValue;
                                    _controller.credentialsManager.autoLogin =
                                        newValue;
                                  },
                            child: Text(
                              'Keep me signed in',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

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
                                : const Row(
                                    children: [
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: SizedBox(),
                                      ), // Balances left side for perfect centering
                                      Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Icon(
                                            Symbols.chevron_right_rounded,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
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
