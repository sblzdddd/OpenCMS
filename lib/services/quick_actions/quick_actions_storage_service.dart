import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../shared/storage_client.dart';

/// Stores user's quick actions preferences as an ordered list of IDs.
class QuickActionsStorageService {
  static final QuickActionsStorageService _instance = QuickActionsStorageService._internal();
  factory QuickActionsStorageService() => _instance;
  QuickActionsStorageService._internal();

  static const String _quickActionsKey = 'quick_actions_preferences';

  FlutterSecureStorage get _storage => StorageClient.instance;

  /// Save quick actions preferences
  Future<bool> saveQuickActionsPreferences(List<String> actionIds) async {
    try {
      final String jsonString = jsonEncode(actionIds);
      await _storage.write(key: _quickActionsKey, value: jsonString);
      print('QuickActionsStorageService: Preferences saved (${actionIds.length} items)');
      return true;
    } catch (e) {
      print('QuickActionsStorageService: Error saving preferences: $e');
      return false;
    }
  }

  /// Load quick actions preferences
  Future<List<String>?> loadQuickActionsPreferences() async {
    try {
      final String? jsonString = await _storage.read(key: _quickActionsKey);
      if (jsonString == null || jsonString.isEmpty) return null;
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is List) {
        final List<String> actionIds = decoded.map<String>((item) => item.toString()).toList();
        print('QuickActionsStorageService: Preferences loaded (${actionIds.length} items)');
        return actionIds;
      }
      return null;
    } catch (e) {
      print('QuickActionsStorageService: Error loading preferences: $e');
      return null;
    }
  }

  /// Clear quick actions preferences
  Future<bool> clearQuickActionsPreferences() async {
    try {
      await _storage.delete(key: _quickActionsKey);
      print('QuickActionsStorageService: Preferences cleared');
      return true;
    } catch (e) {
      print('QuickActionsStorageService: Error clearing preferences: $e');
      return false;
    }
  }

  /// Check if quick actions preferences exist
  Future<bool> hasQuickActionsPreferences() async {
    try {
      final String? value = await _storage.read(key: _quickActionsKey);
      return value != null && value.isNotEmpty;
    } catch (e) {
      print('QuickActionsStorageService: Error checking preferences: $e');
      return false;
    }
  }
}


