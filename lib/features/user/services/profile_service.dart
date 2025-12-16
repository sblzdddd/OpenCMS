/// Profile service for handling user profile data
library;

import 'package:opencms/di/locator.dart';
import 'package:opencms/features/user/models/user_models.dart';

import '../../shared/constants/api_endpoints.dart';
import '../../API/networking/http_service.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  /// Get user profile information
  Future<ProfileResponse> getProfile({bool refresh = false}) async {
    try {
      final response = await di<HttpService>().get(
        API.userProfileUrl,
        refresh: refresh,
      );

      if (response.statusCode == 200 || response.statusCode == 304) {
        return ProfileResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }
}
