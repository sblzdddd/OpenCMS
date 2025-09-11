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
  
  bool get isDarkMode => _isDarkMode;
  ThemeColor get selectedColor => _selectedColor;
  Color get customColor => _customColor;
  
  // Predefined colors
  static const Map<ThemeColor, Color> predefinedColors = {
    ThemeColor.red: Color(0xffb33b15),
    ThemeColor.golden: Color(0xffd4af37),
    ThemeColor.blue: Color(0xff2196f3),
    ThemeColor.green: Color(0xff4caf50),
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
  
  void saveTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setInt('selectedColor', _selectedColor.index);
    await prefs.setInt('customColor', _customColor.toARGB32());
  }
  
  void loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _selectedColor = ThemeColor.values[prefs.getInt('selectedColor') ?? 0];
    _customColor = Color(prefs.getInt('customColor') ?? 0xffb33b15);
    notifyListeners();
  }
}