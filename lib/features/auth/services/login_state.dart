import 'package:logging/logging.dart';
import 'package:opencms/features/user/models/user_models.dart';

final logger = Logger("LoginState");

class LoginState {
  bool _isAuthenticated = false;
  UserInfo? _userInfo;

  bool get isAuthenticated => _isAuthenticated;
  UserInfo? get userInfo => _userInfo;

  /// Set authenticated state with user information
  void setAuthenticated(UserInfo userInfo) {
    _isAuthenticated = true;
    _userInfo = userInfo;

    logger.info('Set ${userInfo.userName} as authenticated user');
  }

  /// Clear authentication state
  void clearAuthentication() {
    logger.info('Authentication cleared for ${_userInfo?.userName ?? "unknown"}');
    _isAuthenticated = false;
    _userInfo = null;
  }

  /// Update user information without changing authentication status
  void updateUserInfo(UserInfo updates) {
    if (_userInfo != null) {
      _userInfo = updates;
      logger.info('User info updated for ${_userInfo?.userName ?? "unknown"}');
    }
  }

  String get currentUsername => _userInfo?.userName ?? '';

  LoginState({bool isAuthenticated = false, UserInfo? userInfo});
}