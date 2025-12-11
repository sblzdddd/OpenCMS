import 'package:get_it/get_it.dart';
import 'package:opencms/features/auth/login_state.dart';
import 'package:opencms/features/auth/services/auto_captcha_service.dart';
import 'package:opencms/features/auth/services/token_refresh_service.dart';
import 'package:opencms/features/core/storage/cookie_storage.dart';
import 'package:opencms/features/core/storage/token_storage.dart';
import 'package:opencms/features/user/services/user_service.dart';
import 'package:opencms/services/services.dart';

final di = GetIt.instance;

void configureDependencies() {
  di.registerSingleton<LoginState>(LoginState());
  di.registerSingleton<CookieStorage>(CookieStorage());
  di.registerSingleton<TokenStorage>(TokenStorage());
  
  di.registerSingleton<TokenRefreshService>(TokenRefreshService());
  di.registerSingleton<HttpService>(HttpService());
  di.registerSingleton<UserService>(UserService());
  di.registerSingleton<AuthService>(AuthService());
  di.registerSingleton<AutoCaptchaService>(AutoCaptchaService());
}
