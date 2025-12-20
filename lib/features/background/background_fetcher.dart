import 'dart:async';
import 'package:opencms/utils/device_info.dart';
import 'package:logging/logging.dart';

final logger = Logger('BackgroundFetcher');

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
    logger.info('$name onUpdate called');
  }

  /// Start background service
  Future<void> start() async {
    if (isRunning || !isDesktopEnvironment) return;

    _startDesktopTimer();
    logger.info('$name started');

    isRunning = true;
  }

  /// Stop background service
  Future<void> stop() async {
    if (!isRunning || !isDesktopEnvironment) return;

    _timer?.cancel();

    isRunning = false;
    logger.info('$name stopped');
  }

  /// Modify fetch interval while running
  Future<void> modifyInterval(Duration newInterval) async {
    interval = newInterval;
    logger.info('$name interval updated to $interval');

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
