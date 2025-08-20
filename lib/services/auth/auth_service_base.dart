import '../shared/http_service.dart';
import '../../data/models/auth/auth_state.dart';

/// Base class for AuthService that provides access to internal services
/// This allows the separated functions to access the necessary services
class AuthServiceBase {
  final HttpService _httpService = HttpService();
  final AuthState _authState = AuthState();
  
  // Getters to provide controlled access to internal services
  HttpService get httpService => _httpService;
  AuthState get authState => _authState;
  
  /// Check if user is currently authenticated
  bool get isAuthenticated => _authState.isAuthenticated;
  
  /// Get current user information
  UserInfo? get userInfo => _authState.userInfo;
}
