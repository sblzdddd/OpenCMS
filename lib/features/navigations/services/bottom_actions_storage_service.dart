import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:opencms/features/API/storage/storage_client.dart';

final logger = Logger('BottomActionsStorageService');

/// Stores user's bottom navigation preferences as an ordered list of IDs.
class BottomActionsStorageService {
  static final BottomActionsStorageService _instance =
      BottomActionsStorageService._internal();
  factory BottomActionsStorageService() => _instance;
  BottomActionsStorageService._internal();

  static const String _bottomActionsKey = 'bottom_actions_preferences';

  StorageClient get _storage => StorageClient.instance;

  /// Save bottom actions preferences
  Future<bool> saveBottomActionsPreferences(List<String> actionIds) async {
    try {
      final String jsonString = jsonEncode(actionIds);
      await _storage.write(key: _bottomActionsKey, value: jsonString);
      logger.info('Preferences saved (${actionIds.length} items)');
      return true;
    } catch (e) {
      logger.severe('Error saving preferences: $e');
      return false;
    }
  }

  /// Load bottom actions preferences
  Future<List<String>?> loadBottomActionsPreferences() async {
    try {
      final String? jsonString = await _storage.read(key: _bottomActionsKey);
      if (jsonString == null || jsonString.isEmpty) return null;
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is List) {
        final List<String> actionIds = decoded
            .map<String>((item) => item.toString())
            .toList();
        logger.info('Preferences loaded (${actionIds.length} items)');
        return actionIds;
      }
      return null;
    } catch (e) {
      logger.severe('Error loading preferences: $e');
      return null;
    }
  }

  /// Clear bottom actions preferences
  Future<bool> clearBottomActionsPreferences() async {
    try {
      await _storage.delete(key: _bottomActionsKey);
      logger.info('Preferences cleared');
      return true;
    } catch (e) {
      logger.severe('Error clearing preferences: $e');
      return false;
    }
  }

  /// Check if bottom actions preferences exist
  Future<bool> hasBottomActionsPreferences() async {
    try {
      final String? value = await _storage.read(key: _bottomActionsKey);
      return value != null && value.isNotEmpty;
    } catch (e) {
      logger.severe('Error checking preferences: $e');
      return false;
    }
  }
}
