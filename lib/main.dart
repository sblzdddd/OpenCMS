import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:logging/logging.dart';
import 'package:opencms/di/locator.dart';
import 'package:opencms/features/system/desktop_tray/tray_service.dart';
import 'package:opencms/features/system/desktop_window/window_service.dart';
import 'package:opencms/features/web_cms/services/webview_service.dart';
import 'package:opencms/utils/color_themes.dart';

import 'app_router.dart';
import 'features/auth/views/pages/auth_wrapper.dart';
import 'features/theme/services/theme_services.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  // Initialize logging
  Logger.root.level = kDebugMode ? Level.FINEST : Level.INFO;
  Logger.root.onRecord.listen((record) {
    print(
      '${record.time} [${record.loggerName}] ${record.level.name}: ${record.message}',
    );
  });

  configureDependencies();
  WidgetsFlutterBinding.ensureInitialized();
  await WebviewService.initWebview();
  // init window manager and effects
  await OCMSWindowService.initWindowManager();
  await OCMSTrayService.initSystemTray();
  // Initialize ThemeNotifier singleton
  await ThemeNotifier.initialize();

  runApp(Phoenix(child: OCMSApp()));
}

class OCMSApp extends StatelessWidget {
  const OCMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeNotifier.instance,
      builder: (context, child) {
        final themeNotifier = ThemeNotifier.instance;
        Color seedColor = themeNotifier.currentColor;
        OCMSColorThemes colorThemes = OCMSColorThemes(context);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "OpenCMS",
          theme: colorThemes.buildLightTheme(seedColor),
          darkTheme: colorThemes.buildDarkTheme(seedColor),
          themeMode: themeNotifier.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const AuthWrapper(),
          onGenerateRoute: AppRouter.generateRoute,
          navigatorObservers: [routeObserver],
          // preserve text dpi scale
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
          },
        );
      },
    );
  }
}
