import 'secure_storage_base.dart';
import 'storage_client.dart';
import 'package:cookie_jar/cookie_jar.dart' show Cookie, PersistCookieJar, Storage;

class CookieStorage {
  final Storage cookieStorage;
  final PersistCookieJar cookieJar;
  CookieStorage._(this.cookieStorage, this.cookieJar);
  
  factory CookieStorage() {
    /// Cookie-jar compatible storage backed by [FlutterSecureStorage].
    final storage = SecureStorageBase(StorageClient.instance, 'cj4');
    final jar = PersistCookieJar(
      persistSession: true,
      storage: storage,
    );
    return CookieStorage._(storage, jar);
  }

  Future<List<Cookie>> get currentCookies async {
    await cookieJar.forceInit();

    final allCookies = <Cookie>[];

    // Get all domain cookies (cookies with domain attribute)
    for (final domainEntry in cookieJar.domainCookies.entries) {
      for (final pathEntry in domainEntry.value.entries) {
        for (final cookieEntry in pathEntry.value.entries) {
          allCookies.add(cookieEntry.value.cookie);
        }
      }
    }

    // Get all host cookies (cookies without domain attribute)
    for (final hostEntry in cookieJar.hostCookies.entries) {
      for (final pathEntry in hostEntry.value.entries) {
        for (final cookieEntry in pathEntry.value.entries) {
          allCookies.add(cookieEntry.value.cookie);
        }
      }
    }

    return allCookies;
  }

  Future<void> setCookies(List<Cookie> cookies) async {
    for (final cookie in cookies) {
      await cookieJar.saveFromResponse(
        Uri.parse(cookie.domain ?? ''),
        [cookie],
      );
    }
  }

  Future<void> clearCookies() async {
    await cookieJar.deleteAll();
  }
}