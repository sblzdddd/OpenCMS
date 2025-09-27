import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'window_effect_service.dart';

extension ColorExtension on Color {
  String toHex() {
    return '#${toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}

enum ThemeColor {
  red,
  golden,
  blue,
  green,
  custom,
}


class ThemeNotifier with ChangeNotifier {
  // Singleton instance
  static ThemeNotifier? _instance;
  static bool _isInitialized = false;
  
  // Private constructor
  ThemeNotifier._internal();
  
  // Static getter to access the singleton instance
  static ThemeNotifier get instance {
    _instance ??= ThemeNotifier._internal();
    return _instance!;
  }
  
  // Initialize the singleton (call this once in main.dart)
  static Future<void> initialize() async {
    if (!_isInitialized) {
      _instance = ThemeNotifier._internal();
      await _instance!._loadThemeAsync();
      await WindowEffectService.initialize();
      _isInitialized = true;
    }
  }
  
  bool _isDarkMode = false;
  ThemeColor _selectedColor = ThemeColor.red;
  Color _customColor = const Color(0xffb33b15); // Default red color
  double _borderRadius = 16.0; // Default border radius
  
  bool get isDarkMode => _isDarkMode;
  ThemeColor get selectedColor => _selectedColor;
  Color get customColor => _customColor;
  double get borderRadius => _borderRadius;
  WindowEffectType get windowEffect => WindowEffectService.instance.windowEffect;
  bool get needTransparentBG => WindowEffectService.instance.needTransparentBG;
  
  // Predefined colors
  static const Map<ThemeColor, Color> predefinedColors = {
    ThemeColor.red: Color(0xffb33b15),
    ThemeColor.golden: Color.fromARGB(255, 255, 221, 96),
    ThemeColor.blue: Color.fromARGB(255, 40, 198, 255),
    ThemeColor.green: Color.fromARGB(255, 76, 175, 97),
  };
  
  // Delegate window effect methods to WindowEffectService
  static List<WindowEffectType> get availableWindowEffects => 
      WindowEffectService.availableWindowEffects;
  
  static String getWindowEffectDisplayName(WindowEffectType effect) => 
      WindowEffectService.getWindowEffectDisplayName(effect);
  
  Color get currentColor {
    if (_selectedColor == ThemeColor.custom) {
      return _customColor;
    }
    return predefinedColors[_selectedColor] ?? predefinedColors[ThemeColor.red]!;
  }
  
  // Get color based on house name
  static Color getHouseColor(String? house) {
    if (house == null || house.isEmpty) {
      return predefinedColors[ThemeColor.red]!; // Default fallback
    }
    
    final houseLower = house.toLowerCase();
    switch (houseLower) {
      case 'metal':
        return predefinedColors[ThemeColor.golden]!;
      case 'fire':
        return predefinedColors[ThemeColor.red]!;
      case 'water':
        return predefinedColors[ThemeColor.blue]!;
      case 'wood':
        return predefinedColors[ThemeColor.green]!;
      default:
        return predefinedColors[ThemeColor.red]!; // Default fallback
    }
  }
  void reapplyWindowEffect() {
    notifyListeners();
    WindowEffectService.instance.reapplyWindowEffect(
      color: currentColor,
      isDarkMode: _isDarkMode,
    );
  }
  
  
  void toggleTheme() {
    print('toggleTheme');
    _isDarkMode = !_isDarkMode;
    saveTheme();
    notifyListeners();
    reapplyWindowEffect();
  }
  
  void setColorTheme(ThemeColor color) {
    _selectedColor = color;
    saveTheme();
    notifyListeners();
    reapplyWindowEffect();
  }
  
  void setCustomColor(Color color) {
    _customColor = color;
    _selectedColor = ThemeColor.custom;
    saveTheme();
    notifyListeners();
    reapplyWindowEffect();
  }
  
  void setBorderRadius(double radius) {
    _borderRadius = radius.clamp(0.0, 50.0); // Clamp between 0 and 50
    saveTheme();
    notifyListeners();
  }
  
  // Convenience methods for common border radius values
  void setBorderRadiusSmall() => setBorderRadius(4.0);
  void setBorderRadiusMedium() => setBorderRadius(8.0);
  void setBorderRadiusLarge() => setBorderRadius(16.0);
  void setBorderRadiusExtraLarge() => setBorderRadius(24.0);
  void setBorderRadiusNone() => setBorderRadius(0.0);
  
  // Window effect methods - delegate to WindowEffectService
  void setWindowEffect(WindowEffectType effect) {
    WindowEffectService.instance.setWindowEffect(effect, color: currentColor, isDarkMode: _isDarkMode);
    saveTheme(); // Save preferences when window effect changes
  }
  
  // Get the current ColorScheme based on theme settings
  ColorScheme getCurrentColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: currentColor,
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
    );
  }
  
  
  double calculateBorderRadius(double multiplier) {
    return (_borderRadius * multiplier).clamp(0.0, 50.0);
  }
  
  BorderRadius getBorderRadiusAll(double multiplier) => 
      BorderRadius.circular(calculateBorderRadius(multiplier));
  
  BorderRadius getBorderRadiusTop(double multiplier) => BorderRadius.only(
    topLeft: Radius.circular(calculateBorderRadius(multiplier)),
    topRight: Radius.circular(calculateBorderRadius(multiplier)),
  );
  
  BorderRadius getBorderRadiusBottom(double multiplier) => BorderRadius.only(
    bottomLeft: Radius.circular(calculateBorderRadius(multiplier)),
    bottomRight: Radius.circular(calculateBorderRadius(multiplier)),
  );
  
  void saveTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setInt('selectedColor', _selectedColor.index);
    await prefs.setInt('customColor', _customColor.toARGB32());
    await prefs.setDouble('borderRadius', _borderRadius);
    await prefs.setInt('windowEffect', WindowEffectService.instance.windowEffect.index);
  }
  
  void loadTheme() async {
    await _loadThemeAsync();
  }
  
  Future<void> _loadThemeAsync() async {
    print('loadTheme');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _selectedColor = ThemeColor.values[prefs.getInt('selectedColor') ?? 0];
    _customColor = Color(prefs.getInt('customColor') ?? 0xffb33b15);
    _borderRadius = prefs.getDouble('borderRadius') ?? 8.0;
    
    // Load window effect preference
    WindowEffectService.instance.windowEffect = WindowEffectType.values[prefs.getInt('windowEffect') ?? 0];
    
    notifyListeners();
    reapplyWindowEffect();
  }
}