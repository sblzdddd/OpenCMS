import 'package:flutter/material.dart';
import 'package:opencms/utils/device_info.dart';
import 'package:window_manager/window_manager.dart';

class OCMSWindowService {
  static Future<void> initWindowManager() async {
    if (!isDesktopEnvironment) return;

    await windowManager.ensureInitialized();

    WindowOptions windowOptions = WindowOptions(
      minimumSize: Size(400, 400),
      center: true,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    await windowManager.setPreventClose(true);
  }
}
