import 'package:get_it/get_it.dart';
import 'package:opencms/features/auth/services/auth_service.dart';
import 'package:opencms/features/auth/services/credentials_storage_service.dart';
import 'package:opencms/features/auth/services/login_state.dart';
import 'package:opencms/features/auth/services/auto_captcha_service.dart';
import 'package:opencms/features/auth/services/token_refresh_service.dart';
import 'package:opencms/features/API/networking/http_service.dart';
import 'package:opencms/features/API/storage/token_storage.dart';
import 'package:opencms/features/system/desktop_window/window_effect_service.dart';
import 'package:opencms/features/theme/services/skin_service.dart';
import 'package:opencms/features/user/services/user_service.dart';

final di = GetIt.instance;

void configureDependencies() {
  di.registerSingleton<LoginState>(LoginState());
  di.registerSingleton<TokenStorage>(TokenStorage());
  di.registerSingleton<CredentialsStorageService>(CredentialsStorageService());
  
  di.registerSingleton<TokenRefreshService>(TokenRefreshService());
  di.registerSingleton<HttpService>(HttpService());
  di.registerSingleton<UserService>(UserService());
  di.registerSingleton<AuthService>(AuthService());
  di.registerSingleton<AutoCaptchaService>(AutoCaptchaService());
  di.registerSingleton<SkinService>(SkinService());
  di.registerSingleton<WindowEffectService>(WindowEffectService());
}
