import 'package:opencms/di/locator.dart';

import '../models/homework_models.dart';
import '../../API/networking/http_service.dart';
import '../../shared/constants/api_endpoints.dart';
import 'package:logging/logging.dart';

final logger = Logger('HomeworkService');

class HomeworkService {
  static final HomeworkService _instance = HomeworkService._internal();
  factory HomeworkService() => _instance;
  HomeworkService._internal();

  /// Fetch homework for a specific academic year with optional filters
  Future<HomeworkResponse> fetchHomework({
    required int academicYear,
    bool refresh = false,
  }) async {
    try {
      logger.info('Fetching homework for year $academicYear');

      final response = await di<HttpService>().get(
        '${API.homeworkUrl}?year=$academicYear',
        refresh: refresh
      );

      if (response.data != null) {
        return HomeworkResponse.fromJson(response.data as List<dynamic>);
      } else {
        throw Exception('Invalid response format: expected JSON array');
      }
    } catch (e, stackTrace) {
      logger.severe('Error fetching homework', e, stackTrace);
      rethrow;
    }
  }
}
