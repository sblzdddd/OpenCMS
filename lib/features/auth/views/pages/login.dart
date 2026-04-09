import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opencms/features/auth/views/components/login_form.dart';
import 'package:opencms/features/settings/privacy_policy.dart';
import 'package:opencms/features/shared/views/widgets/custom_scaffold.dart';
import 'package:opencms/features/shared/views/widgets/custom_scroll_view.dart';
import 'package:opencms/features/theme/services/theme_services.dart';
import 'package:opencms/utils/app_info.dart';
import 'package:opencms/utils/device_id.dart';

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
  String _footerText = '';

  @override
  void initState() {
    super.initState();
    _loadFooter();
  }

  Future<void> _loadFooter() async {
    final String combined = await AppInfoUtil.getCombinedFooterText();
    if (!mounted) return;
    setState(() {
      _footerText = combined;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ThemeNotifier.instance;
    return CustomScaffold(
      skinKey: 'login',
      body: Center(
        child: CustomChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Card(
                  color: Theme.of(context).colorScheme.surface,
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  elevation: 20,
                  shadowColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: themeNotifier.getBorderRadiusAll(2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: LoginForm(
                      usernameController: _usernameController,
                      passwordController: _passwordController,
                      formKey: _formKey,
                      captchaKey: _captchaKey,
                    ),
                  ),
                ),
                RichText(
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
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _footerText.isNotEmpty
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: GestureDetector(
                  onLongPress: () async {
                    final id = await getDeviceId();
                    if (!context.mounted) return;
                    await showDialog(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: const Text('Device Info'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Device ID: ${id ?? 'Unavailable'}'),
                              Text(
                                _footerText,
                                textAlign: TextAlign.left,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: id == null
                                  ? null
                                  : () async {
                                      await Clipboard.setData(
                                        ClipboardData(text: id),
                                      );
                                      if (ctx.mounted) Navigator.of(ctx).pop();
                                    },
                              child: const Text('Copy ID'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(
                    "",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
