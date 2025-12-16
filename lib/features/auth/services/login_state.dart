import 'package:flutter/rendering.dart';
import 'package:opencms/features/user/models/user_models.dart';

class LoginState {
  bool _isAuthenticated = false;
  UserInfo? _userInfo;

  bool get isAuthenticated => _isAuthenticated;
  UserInfo? get userInfo => _userInfo;

  /// Set authenticated state with user information
  void setAuthenticated(UserInfo userInfo) {
    _isAuthenticated = true;
    _userInfo = userInfo;

    debugPrint('[LoginState] User authenticated - ${userInfo.userName}');
  }

  /// Clear authentication state
  void clearAuthentication() {
    _isAuthenticated = false;
    _userInfo = null;

    debugPrint('[LoginState] Authentication cleared');
  }

  /// Update user information without changing authentication status
  void updateUserInfo(UserInfo updates) {
    if (_userInfo != null) {
      _userInfo = updates;
      debugPrint('[LoginState] User info updated');
    }
  }

  String get currentUsername => _userInfo?.userName ?? '';

  LoginState({bool isAuthenticated = false, UserInfo? userInfo});
}