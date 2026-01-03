import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:logging/logging.dart';

final logger = Logger('CaptchaDialogWeb');

/// Web-specific helper for captcha dialog
class WebHelper {
  /// Setup message listener for captcha completion
  static void setupMessageListener({
    required Function() removeListener,
    required Function() closeDialog,
    required Function(dynamic) onSuccess,
    required Function(dynamic) onFail,
  }) {
    void messageListener(web.Event event) {
      if (event.isA<web.MessageEvent>()) {
        final data = (event as web.MessageEvent).data.dartify();

        if (data is Map && data['type'] == 'captchaResult') {
          logger.info(
            'CaptchaDialog: Received captcha result via postMessage: $data',
          );

          // Remove the listener to prevent multiple calls
          web.window.removeEventListener('message', messageListener.toJS);

          // Close the dialog
          closeDialog();

          final payload = data['payload'];
          if (payload is Map) {
            final result = payload['result'];
            final captchaData = payload['data'];

            if (result == 'success') {
              onSuccess(captchaData);
            } else if (result == 'error') {
              onFail(captchaData);
            }
          }
        }
      }
    }

    web.window.addEventListener('message', messageListener.toJS);
  }
}
