/// Handles user authentication state, session validation, and user information
library;

/// User information data model
class UserInfo {
  final String username;
  final int userType;
  final int id;
  final String name;
  final String enName;
  final String language;
  final List<String> permissions;

  const UserInfo({
    required this.username,
    required this.userType,
    required this.id,
    required this.name,
    required this.enName,
    required this.language,
    required this.permissions,
  });

  /// Create UserInfo from JSON map
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      username: json['username'] as String,
      userType: json['user_type'] as int,
      id: json['id'] as int,
      name: json['name'] as String,
      enName: json['en_name'] as String,
      language: json['language'] as String,
      permissions: List<String>.from(json['permissions'] as List),
    );
  }

  /// Convert UserInfo to JSON map
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'user_type': userType,
      'id': id,
      'name': name,
      'en_name': enName,
      'language': language,
      'permissions': permissions,
    };
  }

  /// Create a copy of UserInfo with updated fields
  UserInfo copyWith({
    String? username,
    int? userType,
    int? id,
    String? name,
    String? enName,
    String? language,
    List<String>? permissions,
  }) {
    return UserInfo(
      username: username ?? this.username,
      userType: userType ?? this.userType,
      id: id ?? this.id,
      name: name ?? this.name,
      enName: enName ?? this.enName,
      language: language ?? this.language,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  String toString() {
    return 'UserInfo(username: $username, userType: $userType, id: $id, name: $name, enName: $enName, language: $language, permissions: $permissions)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserInfo &&
        other.username == username &&
        other.userType == userType &&
        other.id == id &&
        other.name == name &&
        other.enName == enName &&
        other.language == language &&
        other.permissions.length == permissions.length &&
        other.permissions.every((permission) => permissions.contains(permission));
  }

  @override
  int get hashCode {
    return username.hashCode ^
        userType.hashCode ^
        id.hashCode ^
        name.hashCode ^
        enName.hashCode ^
        language.hashCode ^
        permissions.hashCode;
  }
}

class AuthState {
  bool _isAuthenticated = false;
  UserInfo? _userInfo;
  DateTime? _loginTime;

  /// Check if user is currently authenticated
  bool get isAuthenticated => _isAuthenticated;
  
  /// Get current user information
  UserInfo? get userInfo => _userInfo;
  
  /// Get login time
  DateTime? get loginTime => _loginTime;
  
  /// Get session duration since login
  Duration? get sessionDuration {
    if (_loginTime == null) return null;
    return DateTime.now().difference(_loginTime!);
  }

  /// Set authenticated state with user information
  void setAuthenticated({
    required UserInfo userInfo,
  }) {
    _isAuthenticated = true;
    _loginTime = DateTime.now();
    _userInfo = userInfo;
    
    print('AuthState: User authenticated - ${userInfo.username}');
  }

  /// Set authenticated state with JSON user information
  void setAuthenticatedFromJson({
    required Map<String, dynamic> userInfoJson,
  }) {
    final userInfo = UserInfo.fromJson(userInfoJson);
    setAuthenticated(userInfo: userInfo);
  }

  /// Clear authentication state
  void clearAuthentication() {
    _isAuthenticated = false;
    _userInfo = null;
    _loginTime = null;
    
    print('AuthState: Authentication cleared');
  }

  /// Check if session has expired (based on time)
  bool isSessionExpired({Duration maxAge = const Duration(minutes: 10)}) {
    if (_loginTime == null) return true;
    return DateTime.now().difference(_loginTime!).compareTo(maxAge) > 0;
  }

  /// Get debug information about current authentication state
  Map<String, dynamic> getDebugInfo() {
    return {
      'isAuthenticated': _isAuthenticated,
      'userInfo': _userInfo?.toJson(),
      'loginTime': _loginTime?.toIso8601String(),
      'sessionDuration': sessionDuration?.inMinutes,
      'sessionExpired': isSessionExpired(),
    };
  }

  /// Update user information without changing authentication status
  void updateUserInfo(UserInfo updates) {
    if (_userInfo != null) {
      _userInfo = updates;
      print('AuthState: User info updated');
    }
  }

  /// Update specific user information fields
  void updateUserInfoFields({
    String? username,
    int? userType,
    int? id,
    String? name,
    String? enName,
    String? language,
    List<String>? permissions,
  }) {
    if (_userInfo != null) {
      _userInfo = _userInfo!.copyWith(
        username: username,
        userType: userType,
        id: id,
        name: name,
        enName: enName,
        language: language,
        permissions: permissions,
      );
      print('AuthState: User info fields updated');
    }
  }
}
