import 'package:tray_manager/tray_manager.dart';
import 'package:opencms/utils/device_info.dart';
import 'tray_listener.dart';

class OCMSTrayService {
  static Future<void> initSystemTray() async {
    if (!isDesktopEnvironment) return;

    String path = 'assets/icon/app_icon.ico';

    // Clear any existing tray
    await trayManager.destroy();
    await trayManager.setIcon(path);

    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(key: 'show_window', label: 'Show'),
          MenuItem.separator(),
          MenuItem(key: 'exit_app', label: 'Exit'),
        ],
      ),
    );
    trayManager.addListener(OCMSTrayListener());
  }
}
