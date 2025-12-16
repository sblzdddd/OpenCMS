import '../models/skin_constants.dart';
import '../models/skin_image_type.dart';

/// Helper class to extract categories from skin constants
class SkinCategoriesHelper {
  /// Get all unique categories from skin constants
  static List<String> getCategories() {
    final categories = <String>{};

    for (final key in defaultImageData.keys) {
      final parts = key.split('.');
      if (parts.isNotEmpty) {
        categories.add(parts.first);
      }
    }

    return categories.toList();
  }

  /// Get all image keys for a specific category
  static List<String> getKeysForCategory(String category) {
    return defaultImageData.keys
        .where((key) => key.startsWith('$category.'))
        .toList();
  }

  /// Get image type for a key
  static SkinImageType getImageTypeForKey(String key) {
    final imageData = defaultImageData[key];
    return imageData?.type ?? SkinImageType.background;
  }
}
