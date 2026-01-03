import 'dart:io';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/features/auth/services/login_state.dart';
import 'package:opencms/di/locator.dart';
import 'package:opencms/features/theme/services/skin_service.dart';
import 'package:opencms/features/theme/views/widgets/skin_background_widget.dart';
import 'package:provider/provider.dart';
import '../../../theme/services/theme_services.dart';
import 'dynamic_gradient_banner.dart';
import '../../../shared/constants/period_constants.dart';
import 'dart:async';
import '../../../user/views/pages/profile.dart';
import '../../../shared/views/widgets/scaled_ink_well.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  bool _hasError = false;

  // Cache the streams to prevent recreation
  late final Stream<String> _greetingStream;
  Timer? _greetingTimer;
  StreamController<String>? _greetingController;
  @override
  bool get wantKeepAlive => true; // Keep the widget alive during drag operations

  @override
  void initState() {
    super.initState();
    _initializeStreams();
  }

  void _initializeStreams() {
    // Create a stream that starts with current value and then updates every minute
    _greetingController = StreamController<String>();
    _greetingController!.add(PeriodConstants.getGreeting(DateTime.now()));

    _greetingTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        _greetingController?.add(PeriodConstants.getGreeting(DateTime.now()));
      }
    });

    _greetingStream = _greetingController!.stream;
    setState(() {
      _isLoading = false;
      _hasError = false;
    });
  }

  @override
  void dispose() {
    _greetingTimer?.cancel();
    _greetingController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool haveImageBg = false;
    if (di<SkinService>().activeSkin != null) {
      final skin = di<SkinService>().activeSkin!;
      final imgData = skin.imageData['home.bannerBackground'];
      if (imgData != null && imgData.hasImage && File(imgData.imagePath!).existsSync()) {
        haveImageBg = true;
      }
    }
    super.build(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    return ScaledInkWell(
      background: (inkWell) => Container(
        decoration: BoxDecoration(
          borderRadius: themeNotifier.getBorderRadiusAll(1.5),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.01),
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.02),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: themeNotifier.needTransparentBG
              ? (!themeNotifier.isDarkMode
                  ? Theme.of(
                      context,
                    ).colorScheme.surfaceBright.withValues(alpha: 0.6)
                  : Theme.of(
                      context,
                    ).colorScheme.surfaceContainer.withValues(alpha: 0.8))
              : Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: themeNotifier.getBorderRadiusAll(1.5),
          child: inkWell,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(0),
        height: 200, // Set a fixed height for the banner
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: themeNotifier.getBorderRadiusAll(1.5),
        ),
        child: ClipRRect(
          borderRadius: themeNotifier.getBorderRadiusAll(1.5),
          child: Stack(
            children: [
              Positioned.fill(child: haveImageBg ? 
                SkinBackgroundWidget(category: 'home.bannerBackground', fallbackColor: Theme.of(context).colorScheme.surface, child: Container()) : 
                const DynamicGradientBanner()),
              // Top left and right positioned elements
              Positioned(
                top: 10,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder<String>(
                      stream: _greetingStream,
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? 'Loading...',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    Text(
                      di<LoginState>().userInfo?.enName ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 24,
                right: 24,
                child: Icon(
                  Symbols.account_circle_rounded,
                  fill: 1,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                ),
              if (_hasError)
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Symbols.error_outline_rounded,
                          color: Colors.red,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Failed to load banner',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
