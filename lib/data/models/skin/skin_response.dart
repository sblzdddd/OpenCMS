import 'skin.dart';

/// Response model for skin operations
class SkinResponse {
  final bool success;
  final String? message;
  final Skin? skin;
  final List<Skin>? skins;
  final String? error;

  const SkinResponse({
    required this.success,
    this.message,
    this.skin,
    this.skins,
    this.error,
  });

  /// Create a successful response with a single skin
  factory SkinResponse.success({
    String? message,
    Skin? skin,
    List<Skin>? skins,
  }) {
    return SkinResponse(
      success: true,
      message: message,
      skin: skin,
      skins: skins,
    );
  }

  /// Create an error response
  factory SkinResponse.error(String error) {
    return SkinResponse(
      success: false,
      error: error,
    );
  }

  /// Check if response has data
  bool get hasData => skin != null || (skins != null && skins!.isNotEmpty);

  /// Get the first skin if available
  Skin? get firstSkin => skin ?? (skins?.isNotEmpty == true ? skins!.first : null);

  @override
  String toString() {
    return 'SkinResponse(success: $success, message: $message, error: $error)';
  }
}
