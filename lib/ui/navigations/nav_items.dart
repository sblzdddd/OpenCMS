import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AppNavItem {
  final String label;
  final IconData icon;

  const AppNavItem({required this.label, required this.icon});
}

List<AppNavItem> appNavItems = [
  AppNavItem(label: 'home.title'.tr(), icon: Symbols.home_rounded),
  AppNavItem(label: 'quickActions.timetable'.tr(), icon: Symbols.calendar_view_day_rounded),
  AppNavItem(label: 'quickActions.homeworks'.tr(), icon: Symbols.book_rounded),
  AppNavItem(label: 'quickActions.assessment'.tr(), icon: Symbols.assignment_rounded),
];
