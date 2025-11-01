import 'package:flutter/material.dart';
import './text_theme_util.dart';
import './global_press_scale.dart';

class OCMSColorThemes {
  late TextTheme textTheme;

  // constructor
  OCMSColorThemes(BuildContext context) {
    textTheme = createTextTheme(context, "Roboto", "EB Garamond");
  }

  ThemeData buildLightTheme(Color seedColor) {
    ColorScheme baseLightColorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );

    // Create custom light color scheme with darker background and white containers
    // with ref to: Today
    ColorScheme lightColorScheme = baseLightColorScheme.copyWith(
      surface: Color.lerp(
        const Color.fromARGB(248, 252, 252, 252),
        seedColor,
        0.04,
      )!,
      surfaceContainer: Color.lerp(Colors.white, seedColor, 0.01)!,
      surfaceContainerHigh: Color.lerp(Colors.white, seedColor, 0.005)!,
      surfaceContainerHighest: Color.lerp(Colors.white, seedColor, 0.02)!,
      surfaceContainerLow: Color.lerp(
        const Color(0xF8F8F8F8),
        seedColor,
        0.02,
      )!,
      surfaceContainerLowest: Color.lerp(
        const Color(0xF6F6F6F6),
        seedColor,
        0.04,
      )!,
      surfaceBright: Color.lerp(Colors.white, seedColor, 0.02)!,
    );

    return ThemeData(
      colorScheme: lightColorScheme,
      textTheme: textTheme.apply(
        bodyColor: lightColorScheme.onSurface,
        displayColor: lightColorScheme.onSurface,
      ),
      extensions: <ThemeExtension<dynamic>>[
        const AppInteractionTheme(scaleDownFactor: 0.9),
      ],
    );
  }

  ThemeData buildDarkTheme(Color seedColor) {
    ColorScheme darkColorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
    return ThemeData(
      colorScheme: darkColorScheme,
      textTheme: textTheme.apply(
        bodyColor: darkColorScheme.onSurface,
        displayColor: darkColorScheme.onSurface,
      ),
      extensions: <ThemeExtension<dynamic>>[
        const AppInteractionTheme(scaleDownFactor: 0.9),
      ],
    );
  }
}
