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

  Future<String?> get refreshToken async => await storage.read('refresh');
  Future<String?> get accessToken async => await storage.read('access');
  Future<String?> get sidNb async => await storage.read('sid_nb');
  Future<String?> get sidScie async => await storage.read('sid_scie');

  Future<void> setRefreshToken(String? token) async {
    if (token == null || token.isEmpty) return;
    await storage.write('refresh', token);
  }

  Future<void> setAccessToken(String? token) async {
    if (token == null || token.isEmpty) return;
    await storage.write('access', token);
  }

  Future<void> setSidNb(String? token) async {
    if (token == null || token.isEmpty) return;
    await storage.write('sid_nb', token);
  }

  Future<void> setSidScie(String? token) async {
    if (token == null || token.isEmpty) return;
    await storage.write('sid_scie', token);
  }

  Future<void> clearAccessToken() async {
    await storage.delete('access');
  }

  Future<void> clearAll() async {
    await storage.delete('access');
    await storage.delete('refresh');
    await storage.delete('sid_nb');
    await storage.delete('sid_scie');
  }
}
