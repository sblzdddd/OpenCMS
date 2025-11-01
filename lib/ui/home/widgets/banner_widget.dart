import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../../services/theme/theme_services.dart';
import 'dynamic_gradient_banner.dart';
import '../../../data/constants/periods.dart';
import '../../../services/auth/auth_service.dart';
import 'dart:async';
import '../../../pages/actions/profile.dart';
import '../../shared/scaled_ink_well.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  bool _hasError = false;
  final _userAuth = AuthService();

  // Cache the streams to prevent recreation
  late final Stream<String> _timeStream;
  late final Stream<String> _greetingStream;
  Timer? _greetingTimer;
  Timer? _timeTimer;
  StreamController<String>? _greetingController;
  StreamController<String>? _timeController;
  @override
  bool get wantKeepAlive => true; // Keep the widget alive during drag operations

  @override
  void initState() {
    super.initState();
    _initializeStreams();
  }

  void _initializeStreams() {
    _timeController = StreamController<String>();
    _timeController!.add(
      '${DateFormat("MMMM dd, HH:mm:ss").format(DateTime.now())} ${PeriodConstants.getPeriodInfoByTime(DateTime.now())?.name ?? ''}',
    );
    _timeTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _timeController!.add(
        '${DateFormat("MMMM dd, HH:mm:ss").format(DateTime.now())} ${PeriodConstants.getPeriodInfoByTime(DateTime.now())?.name ?? ''}',
      ),
    );

    // Create a stream that starts with current value and then updates every minute
    _greetingController = StreamController<String>();
    _greetingController!.add(PeriodConstants.getGreeting(DateTime.now()));

    _greetingTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        _greetingController?.add(PeriodConstants.getGreeting(DateTime.now()));
      }
    });

    _greetingStream = _greetingController!.stream;
    _timeStream = _timeController!.stream;
    setState(() {
      _isLoading = false;
      _hasError = false;
    });
  }

  @override
  void dispose() {
    _timeTimer?.cancel();
    _timeController?.close();
    _greetingTimer?.cancel();
    _greetingController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    return ScaledInkWell(
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
              const Positioned.fill(child: DynamicGradientBanner()),
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
                      _userAuth.authState.userInfo?.enName ?? 'User',
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
              Positioned(
                bottom: 10,
                right: 16,
                child: Row(
                  children: [
                    Icon(
                      Symbols.schedule_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    StreamBuilder<String>(
                      stream: _timeStream,
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? 'Loading...',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ],
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
