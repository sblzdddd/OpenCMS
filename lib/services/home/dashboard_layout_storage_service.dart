import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../shared/storage_client.dart';

/// Stores user's dashboard layout as an ordered list of widget IDs.
class DashboardLayoutStorageService {
  static final DashboardLayoutStorageService _instance = DashboardLayoutStorageService._internal();
  factory DashboardLayoutStorageService() => _instance;
  DashboardLayoutStorageService._internal();

  static const String _layoutKey = 'dashboard_layout_preferences';

  FlutterSecureStorage get _storage => StorageClient.instance;

  Future<bool> saveLayout(List<String> widgetIds) async {
    try {
      final String jsonString = jsonEncode(widgetIds);
      await _storage.write(key: _layoutKey, value: jsonString);
      return true;
    } catch (e) {
      print('DashboardLayoutStorageService: Error saving layout: $e');
      return false;
    }
  }

  Future<List<String>?> loadLayout() async {
    try {
      final String? jsonString = await _storage.read(key: _layoutKey);
      if (jsonString == null || jsonString.isEmpty) return null;
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded.map<String>((item) => item.toString()).toList();
      }
      return null;
    } catch (e) {
      print('DashboardLayoutStorageService: Error loading layout: $e');
      return null;
    }
  }

  Future<bool> clearLayout() async {
    try {
      await _storage.delete(key: _layoutKey);
      return true;
    } catch (e) {
      print('DashboardLayoutStorageService: Error clearing layout: $e');
      return false;
    }
  }
}


