import 'package:logging/logging.dart';

final log = Logger('AutoCaptchaService');

class AutoCaptchaService {
  Future<dynamic> getTicket(String username) async {
    try {
      throw UnimplementedError('AutoCaptchaService.getTicket is not implemented');
    } catch (e) {
      log.severe('Get ticket exception: $e');
      return null;
    }
  }
}
