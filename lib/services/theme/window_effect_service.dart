import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'dart:io';

enum WindowEffectType {
  disabled,
  transparent,
  aero,
  acrylic,
  mica,
  tabbed,
}

class WindowEffectService with ChangeNotifier {
  // Singleton instance
  static WindowEffectService? _instance;
  static bool _isInitialized = false;
  
  // Private constructor
  WindowEffectService._internal();
  
  // Static getter to access the singleton instance
  static WindowEffectService get instance {
    _instance ??= WindowEffectService._internal();
    return _instance!;
  }
  
  // Initialize the singleton (call this once in main.dart)
  static Future<void> initialize() async {
    if (!_isInitialized) {
      _instance ??= WindowEffectService._internal();
      _isInitialized = true;
    }
  }
  
  WindowEffectType windowEffect = WindowEffectType.disabled;
  
  bool get needTransparentBG => windowEffect == WindowEffectType.transparent || windowEffect == WindowEffectType.aero || windowEffect == WindowEffectType.acrylic;
  
  // Platform-specific window effects
  static List<WindowEffectType> get availableWindowEffects {
    if(kIsWeb) return [WindowEffectType.disabled];
    if (Platform.isWindows) {
      return [
        WindowEffectType.disabled,
        WindowEffectType.transparent,
        WindowEffectType.aero,
        WindowEffectType.acrylic,
        WindowEffectType.mica,
        WindowEffectType.tabbed,
      ];
    } else if (Platform.isMacOS) {
      return [
        WindowEffectType.disabled,
        WindowEffectType.transparent,
        WindowEffectType.aero,
        WindowEffectType.acrylic,
      ];
    } else if (Platform.isLinux) {
      return [
        WindowEffectType.disabled,
        WindowEffectType.transparent,
      ];
    }
    return [WindowEffectType.disabled];
  }
  
  // Get display name for window effect
  static String getWindowEffectDisplayName(WindowEffectType effect) {
    switch (effect) {
      case WindowEffectType.disabled:
        return 'Disabled';
      case WindowEffectType.transparent:
        return 'Transparent';
      case WindowEffectType.aero:
        return 'Aero';
      case WindowEffectType.acrylic:
        return 'Acrylic';
      case WindowEffectType.mica:
        return 'Mica';
      case WindowEffectType.tabbed:
        return 'Tabbed';
    }
  }
  
  // Window effect methods
  void setWindowEffect(WindowEffectType effect, {required Color color, required bool isDarkMode}) {
    print('setWindowEffect');
    windowEffect = effect;
    notifyListeners();
    reapplyWindowEffect(color: color, isDarkMode: isDarkMode);
  }
  
  // Public method to reapply window effects (useful when theme changes)
  void reapplyWindowEffect({required Color color, required bool isDarkMode}) {
    _applyWindowEffect(color: color, isDarkMode: isDarkMode);
  }
  
  void _applyWindowEffect({required Color color, required bool isDarkMode}) async {
    try {
      print('Applying window effect: $windowEffect');
      if (windowEffect == WindowEffectType.disabled) {
        await Window.setEffect(effect: WindowEffect.disabled);
      } else {
        WindowEffect flutterEffect = _getFlutterWindowEffect(windowEffect);
        print('info: flutterEffect: $flutterEffect, color: $color, isDarkMode: $isDarkMode');
        
        await Window.setEffect(
          effect: flutterEffect,
          color: flutterEffect == WindowEffect.transparent ? const Color(0x00000000) : color, // Default red color
          dark: isDarkMode,
        );
      }
    } catch (e) {
      print('Failed to apply window effect: $e');
    }
  }
  
  WindowEffect _getFlutterWindowEffect(WindowEffectType effect) {
    switch (effect) {
      case WindowEffectType.disabled:
        return WindowEffect.disabled;
      case WindowEffectType.transparent:
        return WindowEffect.transparent;
      case WindowEffectType.aero:
        return WindowEffect.aero;
      case WindowEffectType.acrylic:
        return WindowEffect.acrylic;
      case WindowEffectType.mica:
        return WindowEffect.mica;
      case WindowEffectType.tabbed:
        return WindowEffect.tabbed;
    }
  }
  
}
