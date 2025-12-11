import 'secure_storage_base.dart';
import 'storage_client.dart';
import 'package:cookie_jar/cookie_jar.dart' show Storage;

class CacheStorage {
  /// Cache storage backed by [FlutterSecureStorage].
  static final Storage cacheStorage = SecureStorageBase(StorageClient.instance, 'ch4');
}