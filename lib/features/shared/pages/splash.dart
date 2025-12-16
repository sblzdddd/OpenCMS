import 'package:flutter/material.dart';
import 'package:opencms/features/shared/views/widgets/custom_app_bar.dart';
import 'package:opencms/features/theme/views/widgets/skin_icon_widget.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/utils/app_info.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _infoText = '';

  @override
  void initState() {
    super.initState();
    _initVersionAndDeviceInfo();
  }

  Future<void> _initVersionAndDeviceInfo() async {
    try {
      final String infoText = await AppInfoUtil.getCombinedFooterText();
      if (!mounted) return;
      setState(() {
        _infoText = infoText;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SkinIcon(
              imageKey: 'global.app_icon',
              fallbackIcon: Symbols.school_rounded,
              fallbackIconColor: Theme.of(context).colorScheme.primary,
              fallbackIconBackgroundColor: Colors.transparent,
              size: 96,
              iconSize: 72,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
      appBar: const PreferredSize(
        preferredSize: Size(double.maxFinite, 50),
        child: CustomAppBar(),
      ),
      bottomNavigationBar: _infoText.isNotEmpty
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  _infoText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
