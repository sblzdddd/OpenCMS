

import 'package:flutter/material.dart';
import 'package:opencms/data/constants/api_endpoints.dart';
import 'package:opencms/features/auth/models/auth_models.dart';
import 'package:opencms/features/core/di/locator.dart';
import 'package:opencms/features/core/networking/http_service.dart';

class UserService {
  /// fetch user account information (for auth validations)
  Future<UserInfo> fetchUserAccountInfo() async {
    try {
      final response = await di<HttpService>().get(API.accountUserUrl);
      final data = UserInfo.fromJson(response.data);
      return data;
    } catch (e) {
      print('[UserService] Exception fetching user account info: $e');
      rethrow;
    }
  }
  /// Fetch user profile information (for profile page)
  Future<UserInfo?> fetchUserProfileInfo() async {
    try {
      final response = await di<HttpService>().get(
        API.userProfileUrl,
      );
      final data = UserInfo.fromJson(response.data);
      return data;
    } catch (e) {
      debugPrint('[UserService] Exception fetching user profile info: $e');
      return null;
    }
  }
}