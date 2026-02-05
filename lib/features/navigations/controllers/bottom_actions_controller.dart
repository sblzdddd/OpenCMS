import 'package:flutter/material.dart';

import '../../shared/constants/quick_actions.dart';
import '../services/bottom_actions_storage_service.dart';
import '../views/nav_items.dart';

class BottomActionsController extends ChangeNotifier {
  final BottomActionsStorageService _storage = BottomActionsStorageService();

  List<AppNavItem> _currentItems = [];
  List<AppNavItem> get currentItems => _currentItems;

  List<AppNavItem> _availableItems = [];
  List<AppNavItem> get availableItems => _availableItems;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  BottomActionsController() {
    _loadItems();
  }

  Future<void> refresh() => _loadItems(); // Expose refresh

  List<AppNavItem> _getAllNavItems() {
    // Start with Home
    final items = [appNavItems.firstWhere((item) => item.id == 'home')];

    // Add all non-web link quick actions
    final actions = QuickActionsConstants.availableActions.where(
      (action) => action.isWebLink != true,
    );

    for (final action in actions) {
      // Avoid duplicate 'home' check if QuickActions contained it (it doesn't usually)
      if (action.id == 'home') continue;

      // Check if already in appNavItems (e.g. predefined ones) to reuse or create new
      items.add(
        AppNavItem(
          id: action.id,
          label: action.shortTitle ?? action.title,
          icon: action.icon is IconData
              ? action.icon
              : Icons.extension, // Handle potential non-IconData
        ),
      );
    }
    return items;
  }

  Future<void> _loadItems() async {
    _isLoading = true;
    notifyListeners();

    final ids = await _storage.loadBottomActionsPreferences();

    // All possible items
    final allItems = _getAllNavItems();

    if (ids != null && ids.isNotEmpty) {
      _currentItems = ids.map((id) {
        return allItems.firstWhere(
          (item) => item.id == id,
          orElse: () => allItems.first,
        );
      }).toList();
      // Remove duplicates if any/safety check
      final seen = <String>{};
      _currentItems.retainWhere((item) => seen.add(item.id));
    } else {
      // Default set: Home + Timetable + Homeworks + Assessment (if available in allItems)
      final defaults = ['home', 'timetable', 'homeworks', 'assessment'];
      _currentItems = allItems
          .where((item) => defaults.contains(item.id))
          .toList();

      // Ensure we have at least Home
      if (_currentItems.isEmpty) {
        _currentItems.add(allItems.first);
      }
    }

    _validateAndFix();
    _updateAvailableItems();

    _isLoading = false;
    notifyListeners();
  }

  void _validateAndFix() {
    // First action must be home
    if (_currentItems.isEmpty || _currentItems.first.id != 'home') {
      _currentItems.removeWhere((item) => item.id == 'home');
      // ensure Home is always available to insert
      _currentItems.insert(
        0,
        appNavItems.firstWhere((item) => item.id == 'home'),
      );
    }

    // Max 5 items
    if (_currentItems.length > 5) {
      _currentItems = _currentItems.sublist(0, 5);
    }
  }

  void _updateAvailableItems() {
    final currentIds = _currentItems.map((e) => e.id).toSet();
    final allItems = _getAllNavItems();
    _availableItems = allItems
        .where((item) => !currentIds.contains(item.id))
        .toList();
  }

  void addItem(AppNavItem item) {
    if (_currentItems.length >= 5) return;
    if (_currentItems.any((e) => e.id == item.id)) return;

    _currentItems.add(item);
    _validateAndFix();
    _updateAvailableItems();
    _save();
    notifyListeners();
  }

  void removeItem(AppNavItem item) {
    if (item.id == 'home') return; // Cannot remove home
    if (_currentItems.length <= 1) return;

    _currentItems.removeWhere((e) => e.id == item.id);
    _validateAndFix();
    _updateAvailableItems();
    _save();
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final AppNavItem item = _currentItems.removeAt(oldIndex);
    _currentItems.insert(newIndex, item);

    _validateAndFix(); // Will enforce Home at top
    _save();
    notifyListeners();
  }

  void reset() {
    _storage.clearBottomActionsPreferences();
    _loadItems();
  }

  Future<void> _save() async {
    final ids = _currentItems.map((e) => e.id).toList();
    await _storage.saveBottomActionsPreferences(ids);
  }
}
