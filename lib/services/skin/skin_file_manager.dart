import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../../data/constants/skin_constants.dart';
import '../../data/models/skin/skin_image.dart';
import 'package:archive/archive_io.dart';

/// Manages file I/O operations for skin customization
class SkinFileManager {
  static Future<void> ensureDirectoryExists(String directoryPath) async {
    if (!await Directory(directoryPath).exists()) {
      await Directory(directoryPath).create(recursive: true);
    }
  }

  static Future<String> getSkinDirectoryPath(String skinId) async {
    final skinsDirectory = await getSkinsDirectory();
    final skinDirectory =
        '${skinsDirectory.path}${Platform.pathSeparator}$skinId';
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
    String key,
  ) async {
    final skinsDirectory = await getSkinDirectoryPath(skinId);

    final sourceFile = File(sourcePath);
    final extension = sourcePath.split('.').last;
    final fileName = '$key.$extension';
    final destinationPath = '$skinsDirectory${Platform.pathSeparator}$fileName';
    print(destinationPath);

    await sourceFile.copy(destinationPath);
    return destinationPath;
  }

  static Future<void> deleteFileIfExists(String? path, String skinId) async {
    if (path != null) {
      final skinsDirectory = await getSkinDirectoryPath(skinId);
      final file = File(path);
      if (file.existsSync() &&
          _isPathWithinDirectory(file.path, skinsDirectory)) {
        print('[SkinFileManager] Deleting file: ${file.path}');
        file.deleteSync();
      }
    }
  }

  static Future<void> deleteSkinFiles(
    Map<String, SkinImageData> imageData,
    String skinId,
  ) async {
    final skinsDirectory = await getSkinDirectoryPath(skinId);
    for (final key in imageData.keys) {
      final path = imageData[key]?.imagePath;
      if (path != null) {
        final file = File(path);
        if (file.existsSync() &&
            _isPathWithinDirectory(file.path, skinsDirectory)) {
          file.deleteSync();
        }
      }
    }
  }

  static Future<File> getSkinJsonFile(String skinId) async {
    final dir = await getSkinDirectoryPath(skinId);
    return File('$dir${Platform.pathSeparator}skin.json');
  }

  static Future<Map<String, dynamic>?> readSkinJsonMap(String skinId) async {
    final file = await getSkinJsonFile(skinId);
    if (!file.existsSync()) return null;
    try {
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static Future<void> writeSkinJsonMap(
    String skinId,
    Map<String, dynamic> json,
  ) async {
    final file = await getSkinJsonFile(skinId);
    await file.writeAsString(jsonEncode(json));
  }

  static Future<void> deleteSkinDirectory(String skinId) async {
    final dirPath = await getSkinDirectoryPath(skinId);
    final dir = Directory(dirPath);
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }

  static Future<String> exportSkinAsCmsk(String skinId) async {
    final skinDirPath = await getSkinDirectoryPath(skinId);
    final skinDir = Directory(skinDirPath);
    if (!skinDir.existsSync()) {
      throw Exception('Skin directory not found for id: $skinId');
    }

    final skinJson = await readSkinJsonMap(skinId);
    if (skinJson == null) {
      throw Exception('skin.json not found for id: $skinId');
    }

    final exportJson = Map<String, dynamic>.from(skinJson);
    if (exportJson.containsKey('imageData')) {
      final imageData = exportJson['imageData'] as Map<String, dynamic>;
      for (final key in imageData.keys) {
        if (imageData[key] is Map<String, dynamic> &&
            imageData[key].containsKey('imagePath')) {
          final imagePath = imageData[key]['imagePath'] as String;
          if (imagePath.isNotEmpty) {
            imageData[key]['imagePath'] = imagePath
                .split(Platform.pathSeparator)
                .last;
          }
        }
      }
    }

    final tempDir = await getTemporaryDirectory();
    final outFilePath = '${tempDir.path}${Platform.pathSeparator}$skinId.cmsk';

    final ZipFileEncoder zipEncoder = ZipFileEncoder();
    zipEncoder.create(outFilePath);

    final skinJsonFile = File('$skinDirPath${Platform.pathSeparator}skin.json');
    await skinJsonFile.writeAsString(jsonEncode(exportJson));
    await zipEncoder.addFile(skinJsonFile);

    if (exportJson.containsKey('imageData')) {
      final imageData = exportJson['imageData'] as Map<String, dynamic>;
      for (final key in imageData.keys) {
        if (imageData[key] is Map<String, dynamic> &&
            imageData[key].containsKey('imagePath')) {
          final fileName = imageData[key]['imagePath'] as String;
          if (fileName.isNotEmpty) {
            final imagePath = '$skinDirPath${Platform.pathSeparator}$fileName';
            if (File(imagePath).existsSync()) {
              // zip.addFile(fileName, imagePath);
              await zipEncoder.addFile(File(imagePath));
            }
          }
        }
      }
    }

    await zipEncoder.close();

    await skinJsonFile.writeAsString(jsonEncode(skinJson));

    return outFilePath;
  }

  static bool _isPathWithinDirectory(String filePath, String directoryPath) {
    try {
      final normalizedFilePath = File(
        filePath,
      ).absolute.path.replaceAll(Platform.pathSeparator, '/');
      final normalizedDirPath = Directory(
        directoryPath,
      ).absolute.path.replaceAll(Platform.pathSeparator, '/');

      return normalizedFilePath.startsWith(normalizedDirPath);
    } catch (e) {
      return false;
    }
  }

  static Future<String> importSkinFromCmsk(String cmskFilePath) async {
    final file = File(cmskFilePath);
    if (!file.existsSync()) {
      throw Exception('Import file not found');
    }

    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final skinJsonEntry = archive.findFile('skin.json');
    if (skinJsonEntry == null) {
      throw Exception('skin.json not found in archive');
    }

    final skinJsonContent = utf8.decode(skinJsonEntry.content);
    final skinJson = jsonDecode(skinJsonContent) as Map<String, dynamic>;

    final newSkinId = DateTime.now().millisecondsSinceEpoch.toString();
    final skinDirPath = await getSkinDirectoryPath(newSkinId);

    for (final entry in archive) {
      if (entry.isFile) {
        final outPath = '$skinDirPath${Platform.pathSeparator}${entry.name}';
        final outFile = File(outPath);
        await outFile.parent.create(recursive: true);
        await outFile.writeAsBytes(entry.content);
      }
    }

    skinJson['id'] = newSkinId;
    if (skinJson.containsKey('imageData')) {
      final imageData = skinJson['imageData'] as Map<String, dynamic>;
      for (final key in imageData.keys) {
        if (imageData[key] is Map<String, dynamic> &&
            imageData[key].containsKey('imagePath')) {
          final fileName = imageData[key]['imagePath'] as String;
          if (fileName.isNotEmpty) {
            imageData[key]['imagePath'] =
                '$skinDirPath${Platform.pathSeparator}$fileName';
          }
        }
      }
    }
    await writeSkinJsonMap(newSkinId, skinJson);

    return newSkinId;
  }
}
