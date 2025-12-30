/// Data class for saved credentials
class SavedCredentials {
  final String username;
  final String password;
  final bool remember;
  final bool autoLogin;
  final bool hasCredentials;

  const SavedCredentials({
    required this.username,
    required this.password,
    required this.remember,
    required this.autoLogin,
    required this.hasCredentials,
  });

  /// Create an empty SavedCredentials object
  factory SavedCredentials.empty() {
    return const SavedCredentials(
      username: '',
      password: '',
      remember: false,
      autoLogin: false,
      hasCredentials: false,
    );
  }

  /// Create a copy with updated values
  SavedCredentials copyWith({
    String? username,
    String? password,
    bool? remember,
    bool? autoLogin,
    bool? hasCredentials,
  }) {
    return SavedCredentials(
      username: username ?? this.username,
      password: password ?? this.password,
      remember: remember ?? this.remember,
      autoLogin: autoLogin ?? this.autoLogin,
      hasCredentials: hasCredentials ?? this.hasCredentials,
    );
  }

  @override
  String toString() {
    return 'SavedCredentials(hasCredentials: $hasCredentials, remember: $remember, autoLogin: $autoLogin, username: ${username.isNotEmpty ? '[REDACTED]' : '[EMPTY]'})';
  }
}

