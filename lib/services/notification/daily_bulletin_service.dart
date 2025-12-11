import 'package:opencms/features/auth/login_state.dart';
import 'package:opencms/features/core/di/locator.dart';

import '../../data/constants/api_endpoints.dart';
import '../../data/models/notification/daily_bulletin_response.dart';
import '../../features/core/networking/http_service.dart';

/// Service for handling daily bulletins from the CMS system
class DailyBulletinService {
  static final DailyBulletinService _instance =
      DailyBulletinService._internal();
  factory DailyBulletinService() => _instance;
  DailyBulletinService._internal();

  /// Get a list of all daily bulletins
  ///
  /// Returns a list of [DailyBulletin] objects
  Future<List<DailyBulletin>> getDailyBulletinsList({
    required String date,
    bool refresh = false,
  }) async {
    try {
      final response = await di<HttpService>().get(
        API.dailyBulletinUrl(date),
        refresh: refresh,
      );

      if (response.data != null) {
        final List<dynamic> notificationsJson = response.data as List<dynamic>;
        return notificationsJson
            .map((json) => DailyBulletin.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Failed to fetch daily bulletins: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching daily bulletins: $e');
    }
  }

  Future<String> getDailyBulletinContentUrl(int dailyBulletinId) async {
    try {
      final username = di<LoginState>().currentUsername;
      if (username.isEmpty) {
        throw Exception('Missing username. Please login again.');
      }
      return '${API.legacyCMSBaseUrl}${API.dailyBulletinDetailUrl(username, dailyBulletinId)}';
    } catch (e) {
      throw Exception('Error fetching daily bulletin content: $e');
    }
  }
}
