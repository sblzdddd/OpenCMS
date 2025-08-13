import 'package:flutter/material.dart';
import 'components/auth/captcha/captcha_input.dart';
import 'components/common/password_input.dart';
import 'controllers/login_controller.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final LoginController _loginController = LoginController();
  final GlobalKey _captchaKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loginController.loadSavedCredentials(
      usernameController: _usernameController,
      passwordController: _passwordController,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _loginController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _loginController,
      builder: (context, _) {
        final isLoading = _loginController.isLoading;
        final isLoadingCredentials = _loginController.isLoadingCredentials;
        return Scaffold(
          body: Stack(
            children: [
              // Background image
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/default-login-bg.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.surface.withAlpha(200),
                      BlendMode.srcOver,
                    ),
                  ),
                ),
              ),
              // Main content
              Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Card(
                      margin: const EdgeInsets.all(24),
                      elevation: 20,
                      color: Colors.white.withAlpha(236),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Stack(
                          children: [
                            // Corner round 'erase' button to clear all form data/state
                            Align(
                              alignment: Alignment.topRight,
                              child: Material(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                shape: const CircleBorder(),
                                child: IconButton(
                                  tooltip: 'Clear form',
                                  icon: const Icon(Symbols.delete_sweep_rounded),
                                  onPressed: isLoading
                                      ? null
                                      : () => _loginController.clearForm(
                                          context: context,
                                          usernameController:
                                              _usernameController,
                                          passwordController:
                                              _passwordController,
                                          captchaKey: _captchaKey,
                                        ),
                                ),
                              ),
                            ),
                            Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Icon(
                                    Symbols.school_rounded,
                                    size: 80,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  Text(
                                    'Welcome Back!',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'Login with your SCIE Account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 32),

                                  // Username field
                                  TextFormField(
                                    controller: _usernameController,
                                    decoration: InputDecoration(
                                      labelText: 'Username',
                                      prefixIcon: Icon(Symbols.person_rounded),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your username';
                                      }
                                      return null;
                                    },
                                    enabled: !isLoading,
                                  ),
                                  const SizedBox(height: 16),

                                  PasswordInput(
                                    controller: _passwordController,
                                    labelText: 'Password',
                                    enabled: !isLoading,
                                  ),
                                  const SizedBox(height: 16),

                                  CaptchaInput(
                                    key: _captchaKey,
                                    onCaptchaStateChanged:
                                        _loginController.onCaptchaStateChanged,
                                    initiallyVerified:
                                        _loginController.isCaptchaVerified,
                                    enabled: !isLoading,
                                  ),
                                  const SizedBox(height: 4),

                                  // Remember me checkbox
                                  CheckboxListTile(
                                    title: Text(
                                      'Remember my credentials',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
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
                                    value: _loginController.rememberMe,
                                    onChanged: isLoading
                                        ? null
                                        : (value) {
                                            _loginController.rememberMe =
                                                value ?? false;
                                          },
                                    activeColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 0,
                                    ),
                                    dense: true,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                  ),
                                  const SizedBox(height: 16),

                                  // Login button
                                  ElevatedButton(
                                    onPressed:
                                        (isLoading || isLoadingCredentials)
                                        ? null
                                        : () {
                                            if (!_formKey.currentState!
                                                .validate()) {
                                              return;
                                            }
                                            _loginController.performLogin(
                                              context,
                                              username:
                                                  _usernameController.text,
                                              password:
                                                  _passwordController.text,
                                              captchaKey: _captchaKey,
                                            );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
