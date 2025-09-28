import 'dart:io';
import '../../data/constants/skin_constants.dart';
import '../../data/models/skin/skin_image.dart';

/// Manages file I/O operations for skin customization
class SkinFileManager {
  static Future<void> ensureDirectoryExists(String directoryPath) async {
    if (!await Directory(directoryPath).exists()) {
      await Directory(directoryPath).create(recursive: true);
    }
  }

  static Future<String> getSkinDirectoryPath(String skinId) async {
    final skinsDirectory = await getSkinsDirectory();
    final skinDirectory = '${skinsDirectory.path}/$skinId';
    await ensureDirectoryExists(skinDirectory);
    return skinDirectory;
  }

  static bool imageExists(String? path) {
    if (path == null || path.isEmpty) return false;
    return File(path).existsSync();
  }

  static Future<String> copyImageToSkinsDirectory(
    String sourcePath, 
    String skinId, 
    String key
  ) async {
    final skinsDirectory = await getSkinDirectoryPath(skinId);
    
    final sourceFile = File(sourcePath);
    final extension = sourcePath.split('.').last;
    final fileName = '${skinId}_$key.$extension';
    final destinationPath = '$skinsDirectory/$fileName';
    print(destinationPath);
    
    await sourceFile.copy(destinationPath);
    return destinationPath;
  }

  static Future<void> deleteFileIfExists(String? path, String skinId) async {
    if (path != null) {
      final skinsDirectory = await getSkinDirectoryPath(skinId);
      final file = File(path);
      if (file.existsSync() && _isPathWithinDirectory(file.path, skinsDirectory)) {
        file.deleteSync();
      }
    }
  }

  static Future<void> deleteSkinFiles(
    Map<String, SkinImageData> imageData, 
    String skinId
  ) async {
    final skinsDirectory = await getSkinDirectoryPath(skinId);
    for (final key in imageData.keys) {
      final path = imageData[key]?.imagePath;
      if (path != null) {
        final file = File(path);
        if (file.existsSync() && _isPathWithinDirectory(file.path, skinsDirectory)) {
          file.deleteSync();
        }
      }
    }
  }

  /// Check if a file path is within the specified directory
  /// This method provides accurate path validation to prevent accidental deletion
  /// of files outside the intended directory
  static bool _isPathWithinDirectory(String filePath, String directoryPath) {
    try {
      // Normalize paths to handle different separators and resolve any relative paths
      final normalizedFilePath = File(filePath).absolute.path;
      final normalizedDirPath = Directory(directoryPath).absolute.path;
      
      // Ensure directory path ends with separator for accurate comparison
      // final dirPathWithSeparator = normalizedDirPath.endsWith(Platform.pathSeparator) 
      //     ? normalizedDirPath 
      //     : '$normalizedDirPath${Platform.pathSeparator}';
      
      // Check if the file path starts with the directory path
      print('isPathWithinDirectory: $normalizedFilePath starts with $normalizedDirPath: ${normalizedFilePath.startsWith(normalizedDirPath)}');
      return normalizedFilePath.startsWith(normalizedDirPath);
    } catch (e) {
      // If there's any error in path processing, err on the side of caution
      // and don't delete the file
      return false;
    }
  }
}
