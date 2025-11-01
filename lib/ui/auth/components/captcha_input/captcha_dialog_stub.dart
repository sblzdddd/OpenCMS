/// Stub implementation for non-web platforms
class WebHelper {
  /// Setup message listener for captcha completion (stub - does nothing on non-web platforms)
  static void setupMessageListener({
    required Function() removeListener,
    required Function() closeDialog,
    required Function(dynamic) onSuccess,
    required Function(dynamic) onFail,
  }) {
    // No-op on non-web platforms
  }
}
