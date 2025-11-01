import 'package:tray_manager/tray_manager.dart';
import 'package:opencms/utils/device_info.dart';
import 'dart:io';
import 'package:window_manager/window_manager.dart';

class OCMSTrayListener with TrayListener {
  @override
  void onTrayIconMouseDown() {
    if (isDesktopEnvironment && Platform.isWindows) {
      windowManager.show();
    } else if (isDesktopEnvironment) {
      trayManager.popUpContextMenu();
    }
  }

  @override
  void onTrayIconRightMouseDown() {
    if (isDesktopEnvironment && Platform.isWindows) {
      trayManager.popUpContextMenu();
    } else if (isDesktopEnvironment) {
      windowManager.show();
    }
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'show_window':
        windowManager.show();
        break;
      case 'exit_app':
        await windowManager.setPreventClose(false);
        await windowManager.close();
        break;
    }
  }
}
