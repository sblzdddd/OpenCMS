import '../../data/constants/api_endpoints.dart';
import '../../data/models/notification/daily_bulletin_response.dart';
import '../../services/auth/auth_service.dart';
import '../shared/http_service.dart';

/// Service for handling daily bulletins from the CMS system
class DailyBulletinService {
  static final DailyBulletinService _instance = DailyBulletinService._internal();
  factory DailyBulletinService() => _instance;
  DailyBulletinService._internal();

  final HttpService _httpService = HttpService();
  final AuthService _authService = AuthService();

  /// Get a list of all daily bulletins
  /// 
  /// Returns a list of [DailyBulletin] objects
  Future<List<DailyBulletin>> getDailyBulletinsList({required String date, bool refresh = false}) async {
    try {
      final response = await _httpService.get(ApiConstants.dailyBulletinUrl(date), refresh: refresh);
      
      if (response.data != null) {
        final List<dynamic> notificationsJson = response.data as List<dynamic>;
        return notificationsJson
            .map((json) => DailyBulletin.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch daily bulletins: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching daily bulletins: $e');
    }
  }

  Future<String> getDailyBulletinContentUrl(int dailyBulletinId) async {
    try {
      final username = await _authService.fetchCurrentUsername();
      if (username.isEmpty) {
        throw Exception('Missing username. Please login again.');
      }
      return '${ApiConstants.legacyCMSBaseUrl}${ApiConstants.dailyBulletinDetailUrl(username, dailyBulletinId)}';
    } catch (e) {
      throw Exception('Error fetching daily bulletin content: $e');
    }
  }
}
