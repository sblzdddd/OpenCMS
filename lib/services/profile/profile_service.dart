/// Profile service for handling user profile data
library;

import '../../data/constants/api_endpoints.dart';
import '../../data/models/profile/profile.dart';
import '../shared/http_service.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final HttpService _httpService = HttpService();

  /// Get user profile information
  /// 
  /// Returns a [ProfileResponse] containing the user's profile data
  /// including general info, basic info, and optional more info and relatives
  Future<ProfileResponse> getProfile({bool refresh = false}) async {
    try {
      final response = await _httpService.get(
        ApiConstants.userProfileUrl,
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

  /// Get user profile with error handling
  /// 
  /// Returns a [ProfileResult] containing either the profile data or error information
  Future<ProfileResult> getProfileSafe({bool refresh = false}) async {
    try {
      final profile = await getProfile(refresh: refresh);
      return ProfileResult.success(profile);
    } catch (e) {
      return ProfileResult.error(e.toString());
    }
  }

  /// Check if user has more detailed information available
  Future<bool> hasMoreInfo({bool refresh = false}) async {
    try {
      final profile = await getProfile(refresh: refresh);
      return profile.hasMoreInfo;
    } catch (e) {
      return false;
    }
  }

  /// Check if user has ID information available
  Future<bool> hasIdInfo({bool refresh = false}) async {
    try {
      final profile = await getProfile(refresh: refresh);
      return profile.hasIdInfo;
    } catch (e) {
      return false;
    }
  }

  /// Get only general information
  Future<GeneralInfo> getGeneralInfo({bool refresh = false}) async {
    final profile = await getProfile(refresh: refresh);
    return profile.generalInfo;
  }

  /// Get only basic information
  Future<BasicInfo> getBasicInfo({bool refresh = false}) async {
    final profile = await getProfile(refresh: refresh);
    return profile.basicInfo;
  }

  /// Get user's display name (prefer English name)
  Future<String> getDisplayName({bool refresh = false}) async {
    final generalInfo = await getGeneralInfo(refresh: refresh);
    return generalInfo.displayName;
  }

  /// Get user's full display name
  Future<String> getFullDisplayName({bool refresh = false}) async {
    final generalInfo = await getGeneralInfo(refresh: refresh);
    return generalInfo.fullDisplayName;
  }

  /// Check if user is a boarding student
  Future<bool> isBoardingStudent({bool refresh = false}) async {
    final basicInfo = await getBasicInfo(refresh: refresh);
    return basicInfo.isBoarding;
  }

  /// Get user's grade
  Future<String> getGrade({bool refresh = false}) async {
    final basicInfo = await getBasicInfo(refresh: refresh);
    return basicInfo.grade;
  }

  /// Get user's house
  Future<String> getHouse({bool refresh = false}) async {
    final basicInfo = await getBasicInfo(refresh: refresh);
    return basicInfo.house;
  }

  /// Get user's dormitory
  Future<String> getDormitory({bool refresh = false}) async {
    final basicInfo = await getBasicInfo(refresh: refresh);
    return basicInfo.dormitory;
  }
}

/// Result wrapper for profile operations
class ProfileResult {
  final bool isSuccess;
  final ProfileResponse? profile;
  final String? error;

  ProfileResult._({
    required this.isSuccess,
    this.profile,
    this.error,
  });

  factory ProfileResult.success(ProfileResponse profile) {
    return ProfileResult._(
      isSuccess: true,
      profile: profile,
    );
  }

  factory ProfileResult.error(String error) {
    return ProfileResult._(
      isSuccess: false,
      error: error,
    );
  }
}
