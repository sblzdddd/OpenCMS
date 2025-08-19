import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AppNavItem {
  final String label;
  final IconData icon;

  const AppNavItem({
    required this.label,
    required this.icon,
  });
}

const List<AppNavItem> appNavItems = [
  AppNavItem(
    label: 'Home',
    icon: Symbols.home_rounded,
  ),
  AppNavItem(
    label: 'Timetable',
    icon: Symbols.calendar_view_day_rounded,
  ),
  AppNavItem(
    label: 'Homework',
    icon: Symbols.book_rounded,
  ),
  AppNavItem(
    label: 'Assessments',
    icon: Symbols.assignment_rounded,
  ),
  AppNavItem(
    label: 'Settings',
    icon: Symbols.settings_rounded,
  ),
];


