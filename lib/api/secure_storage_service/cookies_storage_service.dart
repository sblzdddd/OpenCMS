import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'storage_client.dart';

/// Cookies Storage Service
///
/// Persists HTTP cookies as JSON for session restoration.
class CookiesStorageService {
  static final CookiesStorageService _instance = CookiesStorageService._internal();
  factory CookiesStorageService() => _instance;
  CookiesStorageService._internal();

  static const String _cookiesKey = 'session_cookies_json';

  FlutterSecureStorage get _storage => StorageClient.instance;

  /// Persist cookies as JSON in secure storage
  Future<bool> saveCookies(Map<String, String> cookies) async {
    try {
      final String jsonString = jsonEncode(cookies);
      await _storage.write(key: _cookiesKey, value: jsonString);
      print('CookiesStorageService: Cookies saved (${cookies.length})');
      return true;
    } catch (e) {
      print('CookiesStorageService: Error saving cookies: $e');
      return false;
    }
  }

  /// Load persisted cookies
  Future<Map<String, String>> loadCookies() async {
    try {
      final String? jsonString = await _storage.read(key: _cookiesKey);
      if (jsonString == null || jsonString.isEmpty) return <String, String>{};
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is Map) {
        return decoded.map<String, String>((key, value) => MapEntry(key.toString(), value.toString()));
      }
      return <String, String>{};
    } catch (e) {
      print('CookiesStorageService: Error loading cookies: $e');
      return <String, String>{};
    }
  }

  /// Clear persisted cookies
  Future<bool> clearCookies() async {
    try {
      await _storage.delete(key: _cookiesKey);
      print('CookiesStorageService: Cookies cleared');
      return true;
    } catch (e) {
      print('CookiesStorageService: Error clearing cookies: $e');
      return false;
    }
  }

  /// Whether cookies exist in storage
  Future<bool> hasCookies() async {
    try {
      final String? value = await _storage.read(key: _cookiesKey);
      return value != null && value.isNotEmpty;
    } catch (e) {
      print('CookiesStorageService: Error checking cookies: $e');
      return false;
    }
  }
}


