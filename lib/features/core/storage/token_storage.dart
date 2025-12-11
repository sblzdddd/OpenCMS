import 'secure_storage_base.dart';
import 'storage_client.dart';
import 'package:cookie_jar/cookie_jar.dart' show Storage;

class TokenStorage {
  final Storage storage;
  TokenStorage._(this.storage);
  
  factory TokenStorage() {
    /// Cookie-jar compatible storage backed by [FlutterSecureStorage].
    final storage = SecureStorageBase(StorageClient.instance, 'tkn');
    return TokenStorage._(storage);
  }

  Future<String?> getRefreshToken() async {
    return await storage.read('refresh');
  }

  Future<String?> getAccessToken() async {
    return await storage.read('access');
  }

  Future<void> setRefreshToken(String? token) async {
    if (token == null || token.isEmpty) return;
    await storage.write('refresh', token);
  }

  Future<void> setAccessToken(String? token) async {
    if (token == null || token.isEmpty) return;
    await storage.write('access', token);
  }

  Future<void> clearAll() async {
    await storage.delete('access');
    await storage.delete('refresh');
  }
}
