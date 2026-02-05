import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AppNavItem {
  final String id;
  final String label;
  final IconData icon;

  const AppNavItem({
    required this.id,
    required this.label,
    required this.icon,
  });
}

List<AppNavItem> appNavItems = [
  AppNavItem(id: 'home', label: 'Home', icon: Symbols.home_rounded),
  AppNavItem(id: 'timetable', label: 'Timetable', icon: Symbols.calendar_view_day_rounded),
  AppNavItem(id: 'homeworks', label: 'Homeworks', icon: Symbols.book_rounded),
  AppNavItem(id: 'assessment', label: 'Assessment', icon: Symbols.assignment_rounded),
];
