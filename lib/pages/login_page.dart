import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme/theme_services.dart';
import '../ui/auth/login_form.dart';
import 'package:opencms/ui/shared/widgets/custom_scroll_view.dart';
import 'package:opencms/ui/shared/widgets/custom_scaffold.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey _captchaKey = GlobalKey();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    return CustomScaffold(
      skinKey: 'login',
      body: Center(
        child: CustomChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              color: themeNotifier.needTransparentBG ? (!themeNotifier.isDarkMode
                  ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.6)
                  : Theme.of(context).colorScheme.surface.withValues(alpha: 0.8))
              : Theme.of(context).colorScheme.surface,
              margin: const EdgeInsets.all(24),
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius: themeNotifier.getBorderRadiusAll(2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LoginForm(
                  usernameController: _usernameController,
                  passwordController: _passwordController,
                  formKey: _formKey,
                  captchaKey: _captchaKey,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
