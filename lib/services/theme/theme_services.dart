import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isDarkMode = false;
  ThemeColor _selectedColor = ThemeColor.red;
  Color _customColor = const Color(0xffb33b15); // Default red color
  double _borderRadius = 16.0; // Default border radius
  
  bool get isDarkMode => _isDarkMode;
  ThemeColor get selectedColor => _selectedColor;
  Color get customColor => _customColor;
  double get borderRadius => _borderRadius;
  
  // Predefined colors
  static const Map<ThemeColor, Color> predefinedColors = {
    ThemeColor.red: Color(0xffb33b15),
    ThemeColor.golden: Color.fromARGB(255, 255, 221, 96),
    ThemeColor.blue: Color.fromARGB(255, 40, 198, 255),
    ThemeColor.green: Color.fromARGB(255, 76, 175, 97),
  };
  
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
  
  ThemeNotifier() {
    loadTheme();
  }
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    saveTheme();
    notifyListeners();
  }
  
  void setColorTheme(ThemeColor color) {
    _selectedColor = color;
    saveTheme();
    notifyListeners();
  }
  
  void setCustomColor(Color color) {
    _customColor = color;
    _selectedColor = ThemeColor.custom;
    saveTheme();
    notifyListeners();
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
  
  // Calculate border radius with multiplier
  double calculateBorderRadius(double multiplier) {
    return (_borderRadius * multiplier).clamp(0.0, 50.0);
  }
  
  // Calculate border radius with addition/subtraction
  double calculateBorderRadiusOffset(double offset) {
    return (_borderRadius + offset).clamp(0.0, 50.0);
  }
  
  // Get BorderRadius objects with calculated values
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
  
  BorderRadius getBorderRadiusHorizontal(double multiplier) => BorderRadius.horizontal(
    left: Radius.circular(calculateBorderRadius(multiplier)),
    right: Radius.circular(calculateBorderRadius(multiplier)),
  );
  
  BorderRadius getBorderRadiusLeft(double multiplier) => BorderRadius.only(
    topLeft: Radius.circular(calculateBorderRadius(multiplier)),
    bottomLeft: Radius.circular(calculateBorderRadius(multiplier)),
  );
  
  BorderRadius getBorderRadiusRight(double multiplier) => BorderRadius.only(
    topRight: Radius.circular(calculateBorderRadius(multiplier)),
    bottomRight: Radius.circular(calculateBorderRadius(multiplier)),
  );
  
  // Get BorderRadius objects with offset values
  BorderRadius getBorderRadiusAllOffset(double offset) => 
      BorderRadius.circular(calculateBorderRadiusOffset(offset));
  
  BorderRadius getBorderRadiusTopOffset(double offset) => BorderRadius.only(
    topLeft: Radius.circular(calculateBorderRadiusOffset(offset)),
    topRight: Radius.circular(calculateBorderRadiusOffset(offset)),
  );
  
  BorderRadius getBorderRadiusBottomOffset(double offset) => BorderRadius.only(
    bottomLeft: Radius.circular(calculateBorderRadiusOffset(offset)),
    bottomRight: Radius.circular(calculateBorderRadiusOffset(offset)),
  );
  
  BorderRadius getBorderRadiusLeftOffset(double offset) => BorderRadius.only(
    topLeft: Radius.circular(calculateBorderRadiusOffset(offset)),
    bottomLeft: Radius.circular(calculateBorderRadiusOffset(offset)),
  );
  
  BorderRadius getBorderRadiusRightOffset(double offset) => BorderRadius.only(
    topRight: Radius.circular(calculateBorderRadiusOffset(offset)),
    bottomRight: Radius.circular(calculateBorderRadiusOffset(offset)),
  );
  
  void saveTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setInt('selectedColor', _selectedColor.index);
    await prefs.setInt('customColor', _customColor.toARGB32());
    await prefs.setDouble('borderRadius', _borderRadius);
  }
  
  void loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _selectedColor = ThemeColor.values[prefs.getInt('selectedColor') ?? 0];
    _customColor = Color(prefs.getInt('customColor') ?? 0xffb33b15);
    _borderRadius = prefs.getDouble('borderRadius') ?? 8.0;
    notifyListeners();
  }
}