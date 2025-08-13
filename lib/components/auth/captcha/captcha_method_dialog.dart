import 'package:flutter/material.dart';
import '../../../api/captcha_solver/captcha_solver_exports.dart';

class CaptchaMethodDialog extends StatefulWidget {
  const CaptchaMethodDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => const Dialog(child: CaptchaMethodDialog()),
    );
    return saved ?? false;
  }

  @override
  State<CaptchaMethodDialog> createState() => _CaptchaMethodDialogState();
}

class _CaptchaMethodDialogState extends State<CaptchaMethodDialog> {
  CaptchaVerificationMethod _method = CaptchaVerificationMethod.manual;
  final TextEditingController _apiKeyController = TextEditingController();
  bool _forceAutoSolve = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = CaptchaSettingsService();
    final method = await settings.getMethod();
    final apiKey = await settings.getSolveCaptchaApiKey() ?? '';
    final forceAutoSolve = await settings.getForceAutoSolve();
    setState(() {
      _method = method;
      _apiKeyController.text = apiKey;
      _forceAutoSolve = forceAutoSolve;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final settings = CaptchaSettingsService();
    if (_method == CaptchaVerificationMethod.solveCaptcha) {
      if (_apiKeyController.text.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please input your solvecaptcha API key'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      await settings.setSolveCaptchaApiKey(_apiKeyController.text.trim());
      await settings.setForceAutoSolve(_forceAutoSolve);
    }
    await settings.setMethod(_method);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Captcha verification method',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          RadioListTile<CaptchaVerificationMethod>(
            value: CaptchaVerificationMethod.manual,
            groupValue: _method,
            onChanged: (v) =>
                setState(() => _method = v ?? CaptchaVerificationMethod.manual),
            title: const Text('Manually (default)'),
          ),
          RadioListTile<CaptchaVerificationMethod>(
            value: CaptchaVerificationMethod.solveCaptcha,
            groupValue: _method,
            onChanged: (v) =>
                setState(() => _method = v ?? CaptchaVerificationMethod.manual),
            title: const Text('By solvecaptcha.com'),
          ),
          if (_method == CaptchaVerificationMethod.solveCaptcha) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(left: 20),
              child: TextField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API key',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(left: 20),
              child: CheckboxListTile(
                value: _forceAutoSolve,
                onChanged: (value) {
                  setState(() {
                    _forceAutoSolve = value ?? false;
                  });
                },
                title: const Text('Force to login (not recommended)'),
                subtitle: const Text(
                  'Solvecaptcha requires a large amount of time (10~20secs) to solve a captcha, it is only recommended to auto-solve captcha for background tasks / notifications.',
                  style: TextStyle(fontSize: 12),
                ),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(onPressed: _save, child: const Text('Save')),
          ),
        ],
      ),
    );
  }
}
