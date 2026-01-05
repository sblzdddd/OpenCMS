import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:opencms/features/auth/services/login_state.dart';
import 'package:opencms/features/auth/services/token_refresh_service.dart';
import 'package:opencms/di/locator.dart';
import 'package:opencms/features/API/storage/token_storage.dart';

final log = Logger('FileLogInterceptor');

// manages auth headers and token refreshing
class FileLogInterceptor extends Interceptor {
  final TokenStorage storage = di<TokenStorage>();
  final LoginState loginState = di<LoginState>();
  final TokenRefreshService tokenRefreshService = di<TokenRefreshService>();

  FileLogInterceptor();

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    String path = response.realUri.toString().replaceAll('https://', '').replaceAll('http://', '');
    if (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    final dir = path.substring(0, path.lastIndexOf('/')).replaceAll(RegExp(r'[<>:"\\|?*]'), '_');
    final fileName = '${path.substring(path.lastIndexOf('/') + 1).replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')}.json';
    log.info(dir, fileName);
    final directory = await Directory(dir).create(recursive: true);
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(jsonEncode(response.data));
    return handler.next(response);
  }
}
