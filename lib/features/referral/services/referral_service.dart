/// Referral comments service for fetching student referral data
library;

import 'package:opencms/di/locator.dart';

import '../../shared/constants/api_endpoints.dart';
import '../models/referral.dart';
import '../../API/networking/http_service.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

final logger = Logger('ReferralService');

/// Service for handling referral comments API calls
class ReferralService {
  static final ReferralService _instance = ReferralService._internal();
  factory ReferralService() => _instance;
  ReferralService._internal();

  /// Fetch referral comments for the current student
  Future<ReferralResponse> getReferralComments({bool refresh = false}) async {
    try {
      logger.info(
        'Fetching referral comments (refresh: $refresh)',
      );

      final response = await di<HttpService>().get(
        API.referralUrl,
        refresh: refresh,
      );

      logger.info('Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 304) {
        final List<dynamic> data = response.data as List<dynamic>;
        final referralResponse = ReferralResponse.fromJson(data);

        logger.info(
          'Successfully fetched ${referralResponse.comments.length} referral comments',
        );
        return referralResponse;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message:
              'Failed to fetch referral comments. Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      logger.severe('DioException - ${e.message}', e, e.stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      logger.severe('Unexpected error - $e', e, stackTrace);
      throw Exception('Failed to fetch referral comments: $e');
    }
  }
}
