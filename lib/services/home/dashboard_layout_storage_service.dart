import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../shared/storage_client.dart';

/// Stores user's dashboard layout as an ordered list of widget IDs with their sizes.
class DashboardLayoutStorageService {
  static final DashboardLayoutStorageService _instance =
      DashboardLayoutStorageService._internal();
  factory DashboardLayoutStorageService() => _instance;
  DashboardLayoutStorageService._internal();

  static const String _layoutKey = 'dashboard_layout_preferences';

  FlutterSecureStorage get _storage => StorageClient.instance;

  Future<bool> saveLayout(List<MapEntry<String, Size>> widgetOrder) async {
    try {
      // Convert Size objects to serializable format
      final List<Map<String, dynamic>> serializableLayout = widgetOrder.map((
        entry,
      ) {
        return {
          'id': entry.key,
          'width': entry.value.width,
          'height': entry.value.height,
        };
      }).toList();

      final String jsonString = jsonEncode(serializableLayout);
      await _storage.write(key: _layoutKey, value: jsonString);
      return true;
    } catch (e) {
      debugPrint('[DashboardLayoutStorageService] Error saving layout: $e');
      return false;
    }
  }

  Future<List<MapEntry<String, Size>>?> loadLayout() async {
    try {
      final String? jsonString = await _storage.read(key: _layoutKey);
      if (jsonString == null || jsonString.isEmpty) return null;

      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is List) {
        final List<MapEntry<String, Size>> layout = [];
        for (final item in decoded) {
          if (item is Map<String, dynamic> &&
              item.containsKey('id') &&
              item.containsKey('width') &&
              item.containsKey('height')) {
            layout.add(
              MapEntry(
                item['id'].toString(),
                Size(item['width'].toDouble(), item['height'].toDouble()),
              ),
            );
          }
        }
        return layout.isNotEmpty ? layout : null;
      }
      return null;
    } catch (e) {
      debugPrint('[DashboardLayoutStorageService] Error loading layout: $e');
      return null;
    }
  }

  Future<bool> clearLayout() async {
    try {
      await _storage.delete(key: _layoutKey);
      return true;
    } catch (e) {
      debugPrint('[DashboardLayoutStorageService] Error clearing layout: $e');
      return false;
    }
  }
}
