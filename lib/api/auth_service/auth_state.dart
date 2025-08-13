/// Authentication state management
/// 
/// Handles user authentication state, session validation, and user information
library;

class AuthState {
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userInfo;
  DateTime? _loginTime;

  /// Check if user is currently authenticated
  bool get isAuthenticated => _isAuthenticated;
  
  /// Get current user information
  Map<String, dynamic>? get userInfo => _userInfo;
  
  /// Get login time
  DateTime? get loginTime => _loginTime;
  
  /// Get session duration since login
  Duration? get sessionDuration {
    if (_loginTime == null) return null;
    return DateTime.now().difference(_loginTime!);
  }

  /// Set authenticated state with user information
  void setAuthenticated({
    required String username,
    Map<String, dynamic>? additionalInfo,
  }) {
    _isAuthenticated = true;
    _loginTime = DateTime.now();
    _userInfo = {
      'username': username,
      'loginTime': _loginTime!.toIso8601String(),
      ...?additionalInfo,
    };
    
    print('AuthState: User authenticated - $username');
  }

  /// Clear authentication state
  void clearAuthentication() {
    _isAuthenticated = false;
    _userInfo = null;
    _loginTime = null;
    
    print('AuthState: Authentication cleared');
  }

  /// Check if session has expired (based on time)
  bool isSessionExpired({Duration maxAge = const Duration(hours: 24)}) {
    if (_loginTime == null) return true;
    return DateTime.now().difference(_loginTime!).compareTo(maxAge) > 0;
  }

  /// Get debug information about current authentication state
  Map<String, dynamic> getDebugInfo() {
    return {
      'isAuthenticated': _isAuthenticated,
      'userInfo': _userInfo,
      'loginTime': _loginTime?.toIso8601String(),
      'sessionDuration': sessionDuration?.inMinutes,
      'sessionExpired': isSessionExpired(),
    };
  }

  /// Update user information without changing authentication status
  void updateUserInfo(Map<String, dynamic> updates) {
    if (_userInfo != null) {
      _userInfo!.addAll(updates);
      print('AuthState: User info updated');
    }
  }
}
