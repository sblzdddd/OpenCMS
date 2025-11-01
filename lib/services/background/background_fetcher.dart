import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:opencms/utils/device_info.dart';

class BackgroundFetcher {
  Timer? _timer;
  bool isRunning = false;
  final String name;
  final String taskId;
  final String storageKey;
  Duration interval;

  BackgroundFetcher({
    required this.name,
    required this.taskId,
    required this.storageKey,
    this.interval = const Duration(minutes: 5),
  });

  /// Override for your background task logic
  Future<void> onUpdate() async {
    debugPrint('BackgroundFetcher: $name update');
  }

  /// Start background service
  Future<void> start() async {
    if (isRunning || !isDesktopEnvironment) return;

    _startDesktopTimer();
    debugPrint('BackgroundFetcher: $name started (desktop)');

    isRunning = true;
  }

  /// Stop background service
  Future<void> stop() async {
    if (!isRunning || !isDesktopEnvironment) return;

    _timer?.cancel();

    isRunning = false;
    debugPrint('BackgroundFetcher: $name stopped');
  }

  /// Modify fetch interval while running
  Future<void> modifyInterval(Duration newInterval) async {
    interval = newInterval;
    debugPrint('BackgroundFetcher: $name interval updated to $interval');

    if (isRunning) {
      await stop();
      await start();
    }
  }

  /// Internal: start timer for desktop
  void _startDesktopTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) async {
      await onUpdate();
    });
  }

  Future<void> check(String task) async {
    if (task == taskId) {
      await onUpdate();
    }
  }
}
