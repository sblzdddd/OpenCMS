import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../data/constants/period_constants.dart';
import '../../../services/auth/auth_service.dart';
import 'dart:async';

enum BannerType { dynamicGradient, vantaTopology }

class BannerCard extends StatefulWidget {
  final BannerType bannerType;

  const BannerCard({super.key, this.bannerType = BannerType.dynamicGradient});

  @override
  State<BannerCard> createState() => _BannerCardState();
}

class _BannerCardState extends State<BannerCard> with AutomaticKeepAliveClientMixin {
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
    _timeController!.add('${DateFormat("MMMM dd, HH:mm:ss").format(DateTime.now())} ${PeriodConstants.getPeriodInfoByTime(DateTime.now())?.name ?? ''}');
    _timeTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _timeController!.add('${DateFormat("MMMM dd, HH:mm:ss").format(DateTime.now())} ${PeriodConstants.getPeriodInfoByTime(DateTime.now())?.name ?? ''}')
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Container(
      padding: const EdgeInsets.all(0),
      height: 200, // Set a fixed height for the banner
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            InAppWebView(
              initialFile: "assets/static/${_getHtmlFileName()}",
              initialSettings: InAppWebViewSettings(
                mediaPlaybackRequiresUserGesture: false,
                disableHorizontalScroll: true,
                disableVerticalScroll: true,
                supportZoom: false,
                useWideViewPort: false,
                loadWithOverviewMode: false,
              ),
              onLoadStart: (controller, url) {
                if (mounted) {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                }
              },
              onLoadStop: (controller, url) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              onReceivedError: (controller, request, error) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
                debugPrint('WebView load error: $error');
              },
            ),
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
                      return Text(snapshot.data ?? 'Loading...', style: const TextStyle(fontSize: 16, color: Colors.white));
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
                      return Text(snapshot.data ?? 'Loading...', style: const TextStyle(fontSize: 12, color: Colors.white));
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
                      Icon(Symbols.error_outline_rounded, color: Colors.red, size: 32),
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
    );
  }

  String _getHtmlFileName() {
    switch (widget.bannerType) {
      case BannerType.dynamicGradient:
        return 'DynamicBanner.html';
      case BannerType.vantaTopology:
        return 'VantaBanner1.html';
    }
  }
}
