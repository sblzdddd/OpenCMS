import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/skin.dart';
import '../models/skin_image.dart';
import '../models/skin_response.dart';
import '../models/skin_constants.dart';
import 'skin_file_manager.dart';
import 'package:logging/logging.dart';

final logger = Logger('SkinService');

/// Service for managing skin configurations and image files
class SkinService extends ChangeNotifier {
  static const String _skinsKey = skinsKey; // store only IDs
  static const String _activeSkinKey = activeSkinKey; // active skin id only

  final ImagePicker _imagePicker = ImagePicker();

  /// Current active skin
  Skin? _activeSkin;

  /// Get the current active skin
  Skin? get activeSkin => _activeSkin;

  /// Initialize the skin service
  Future<void> initialize() async {}

  /// Get a skin by its ID
  Future<SkinResponse> getSkinById(String skinId) async {
    try {
      final allSkinsResponse = await getAllSkins();
      if (!allSkinsResponse.success) {
        return allSkinsResponse;
      }

      final skins = allSkinsResponse.skins ?? [];
      final skin = skins.firstWhere(
        (s) => s.id == skinId,
        orElse: () {
          logger.warning('Skin not found for id: $skinId');
          throw Exception('Skin not found');
        },
      );

      return SkinResponse.success(skin: skin);
    } catch (e, stackTrace) {
      logger.severe('Failed to get skin by id: $e', e, stackTrace);
      return SkinResponse.error('Failed to get skin by id: $e');
    }
  }

  /// Get all available skins (excluding default skin)
  Future<SkinResponse> getAllSkins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final skinIds = prefs.getStringList(_skinsKey) ?? <String>[];
      final activeSkinId = prefs.getString(_activeSkinKey);

      final List<Skin> skins = [];
      for (final id in skinIds) {
        final map = await SkinFileManager.readSkinJsonMap(id);
        if (map == null) {
          // Skip missing or invalid skins (no backward-compat required)
          continue;
        }
        final skin = Skin.fromJson(map);
        skins.add(skin);
      }

      // Ensure only one skin is active at a time
      if (activeSkinId != null && activeSkinId != 'default') {
        for (var skin in skins) {
          skin.isActive = (skin.id == activeSkinId);
        }
      } else {
        // If activeSkinId is 'default' or null, deactivate all stored skins
        for (var skin in skins) {
          skin.isActive = false;
        }
      }

      // Sort skins by creation date (newest first)
      skins.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return SkinResponse.success(skins: skins);
    } catch (e, stackTrace) {
      logger.severe('Failed to load skins: $e', e, stackTrace);
      return SkinResponse.error('Failed to load skins: $e');
    }
  }

  /// Get the currently active skin
  Future<SkinResponse> getActiveSkin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activeSkinId = prefs.getString(_activeSkinKey);

      if (activeSkinId == null || activeSkinId == 'default') {
        // Return default skin if no active skin is set or default is selected
        final defaultSkin = createDefaultSkin();
        _activeSkin = defaultSkin;
        notifyListeners();
        return SkinResponse.success(skin: defaultSkin);
      }

      final map = await SkinFileManager.readSkinJsonMap(activeSkinId);
      if (map == null) {
        final defaultSkin = createDefaultSkin();
        _activeSkin = defaultSkin;
        notifyListeners();
        return SkinResponse.success(skin: defaultSkin);
      }

      _activeSkin = Skin.fromJson(map).copyWith(isActive: true);
      notifyListeners();
      return SkinResponse.success(skin: _activeSkin);
    } catch (e, stackTrace) {
      logger.severe('Failed to get active skin: $e', e, stackTrace);
      return SkinResponse.error('Failed to get active skin: $e');
    }
  }

  /// Create a new skin
  Future<SkinResponse> createSkin({
    required String name,
    required String description,
    required String author,
  }) async {
    try {
      logger.info("Creating new skin: $name by $author");
      final skin = Skin(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        author: author,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Persist skin.json and store ID in prefs list
      await SkinFileManager.writeSkinJsonMap(skin.id, skin.toJson());
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_skinsKey) ?? <String>[];
      if (!ids.contains(skin.id)) {
        ids.add(skin.id);
        await prefs.setStringList(_skinsKey, ids);
      }

      return SkinResponse.success(
        message: 'Skin created successfully',
        skin: skin,
      );
    } catch (e, stackTrace) {
      logger.severe('Failed to create skin: $e', e, stackTrace);
      return SkinResponse.error('Failed to create skin: $e');
    }
  }

  /// Update an existing skin
  Future<SkinResponse> updateSkin(Skin skin) async {
    try {
      logger.info("Updating skin: ${skin.name} by ${skin.author}");
      final updatedSkin = skin.copyWith(updatedAt: DateTime.now());
      await SkinFileManager.writeSkinJsonMap(
        updatedSkin.id,
        updatedSkin.toJson(),
      );
      return SkinResponse.success(skin: updatedSkin);
    } catch (e, stackTrace) {
      logger.severe('Failed to update skin: $e', e, stackTrace);
      return SkinResponse.error('Failed to update skin: $e');
    }
  }

  /// Delete a skin
  Future<SkinResponse> deleteSkin(String skinId) async {
    try {
      logger.info('Deleting skin with id: $skinId');
      // Remove from ID list and delete files on disk
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_skinsKey) ?? <String>[];
      if (!ids.contains(skinId)) {
        return SkinResponse.error('Skin not found');
      }

      // If this was the active skin, set default as active
      final activeSkinId = prefs.getString(_activeSkinKey);
      if (activeSkinId == skinId) {
        await prefs.remove(_activeSkinKey);
      }

      ids.removeWhere((id) => id == skinId);
      await prefs.setStringList(_skinsKey, ids);

      await SkinFileManager.deleteSkinDirectory(skinId);

      return SkinResponse.success(message: 'Skin deleted successfully');
    } catch (e, stackTrace) {
      logger.severe('Failed to delete skin: $e', e, stackTrace);
      return SkinResponse.error('Failed to delete skin: $e');
    }
  }

  Future<SkinResponse> setActiveSkin(String skinId) async {
    try {
      logger.info('Setting active skin to id: $skinId');
      // Validate the skin exists by checking skin.json
      final map = await SkinFileManager.readSkinJsonMap(skinId);
      if (map == null) {
        logger.warning('Skin not found for id: $skinId');
        return SkinResponse.error('Skin not found');
      }

      // Save active skin ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeSkinKey, skinId);

      // Update cached active skin and notify listeners
      _activeSkin = Skin.fromJson(map).copyWith(isActive: true);
      notifyListeners();

      return SkinResponse.success(
        message: 'Skin activated successfully',
        skin: _activeSkin,
      );
    } catch (e, stackTrace) {
      logger.severe('Failed to set active skin: $e', e, stackTrace);
      return SkinResponse.error('Failed to set active skin: $e');
    }
  }

  /// Clear the active skin (reset to default)
  Future<SkinResponse> clearActiveSkin() async {
    try {
      logger.info('Clearing active skin to default');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeSkinKey, 'default');

      // Update cached active skin to default and notify listeners
      final defaultSkin = createDefaultSkin();
      _activeSkin = defaultSkin;
      notifyListeners();

      return SkinResponse.success(
        message: 'Default skin is now active',
        skin: defaultSkin,
      );
    } catch (e, stackTrace) {
      logger.severe('Failed to clear active skin: $e', e, stackTrace);
      return SkinResponse.error('Failed to clear active skin: $e');
    }
  }

  /// Pick and set an image for a skin
  Future<SkinResponse> pickAndSetImage({
    required String skinId,
    required String key,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85, // Compress images to save space
      );

      if (pickedFile == null) {
        logger.fine('No image selected for skinId: $skinId, key: $key');
        return SkinResponse.error('No image selected');
      }

      return await setSkinImage(
        skinId: skinId,
        key: key,
        imagePath: pickedFile.path,
      );
    } catch (e, stackTrace) {
      logger.severe('Failed to pick image: $e', e, stackTrace);
      return SkinResponse.error('Failed to pick image: $e');
    }
  }

  /// Set an image for a skin from file path
  Future<SkinResponse> setSkinImage({
    required String skinId,
    required String key,
    required String imagePath,
  }) async {
    try {
      logger.info('Setting image for skinId: $skinId, key: $key');
      final map = await SkinFileManager.readSkinJsonMap(skinId);
      if (map == null) return SkinResponse.error('Skin not found');
      final skin = Skin.fromJson(map);

      final updatedSkin = await skin.setImagePath(key, imagePath);
      if (updatedSkin == null) return SkinResponse.error('Failed to set image');

      // Update cached active skin if this is the active skin
      if (_activeSkin?.id == skinId) {
        _activeSkin = updatedSkin;
        notifyListeners();
      }

      return SkinResponse.success(
        message: 'Image set successfully',
        skin: updatedSkin,
      );
    } catch (e, stackTrace) {
      logger.severe('Failed to set image: $e', e, stackTrace);
      return SkinResponse.error('Failed to set image: $e');
    }
  }

  /// Remove an image from a skin
  Future<SkinResponse> removeSkinImage({
    required String skinId,
    required String key,
  }) async {
    try {
      logger.info('Removing image for skinId: $skinId, key: $key');
      final map = await SkinFileManager.readSkinJsonMap(skinId);
      if (map == null) return SkinResponse.error('Skin not found');
      final skin = Skin.fromJson(map);

      final updatedSkin = await skin.setImagePath(key, null);
      if (updatedSkin == null) {
        return SkinResponse.error('Failed to remove image');
      }

      // Update cached active skin if this is the active skin
      if (_activeSkin?.id == skinId) {
        _activeSkin = updatedSkin;
        notifyListeners();
      }

      return SkinResponse.success(
        message: 'Image removed successfully',
        skin: updatedSkin,
      );
    } catch (e, stackTrace) {
      logger.severe('Failed to remove image: $e', e, stackTrace);
      return SkinResponse.error('Failed to remove image: $e');
    }
  }

  /// Update image data for a specific image key in a skin
  Future<SkinResponse> updateSkinImageData({
    required String skinId,
    required String imageKey,
    required SkinImageData updatedImageData,
  }) async {
    try {
      logger.info('Updating image data for skinId: $skinId, imageKey: $imageKey');
      final map = await SkinFileManager.readSkinJsonMap(skinId);
      if (map == null) return SkinResponse.error('Skin not found');
      final skin = Skin.fromJson(map);

      final updatedSkin = await skin.setImageData(imageKey, updatedImageData);
      if (updatedSkin == null) {
        return SkinResponse.error('Failed to update image data');
      }

      // Update cached active skin if this is the active skin
      if (_activeSkin?.id == skinId) {
        _activeSkin = updatedSkin;
        notifyListeners();
      }

      return SkinResponse.success(
        message: 'Image data updated successfully',
        skin: updatedSkin,
      );
    } catch (e, stackTrace) {
      logger.severe('Failed to update image data: $e', e, stackTrace);
      return SkinResponse.error('Failed to update image data: $e');
    }
  }

  Skin createDefaultSkin() {
    return Skin(
      id: 'default',
      name: 'Default',
      author: 'sblzdddd',
      description: 'The vanilla look for the app',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDefault: true,
      isActive: false, // Will be set to true when selected
    );
  }

  /// Export a skin into a .cmsk package and return the file path
  Future<String> exportSkinToCmsk(String skinId) async {
    // Validate existence first
    final map = await SkinFileManager.readSkinJsonMap(skinId);
    if (map == null) {
      throw Exception('Skin not found');
    }
    return SkinFileManager.exportSkinAsCmsk(skinId);
  }

  /// Import a skin from a .cmsk file
  Future<SkinResponse> importSkinFromCmsk(String cmskFilePath) async {
    try {
      // Import and extract the skin package
      final newSkinId = await SkinFileManager.importSkinFromCmsk(cmskFilePath);

      // Add the new skin ID to the list of skins
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_skinsKey) ?? <String>[];
      if (!ids.contains(newSkinId)) {
        ids.add(newSkinId);
        await prefs.setStringList(_skinsKey, ids);
      }

      // Load and return the imported skin
      final map = await SkinFileManager.readSkinJsonMap(newSkinId);
      if (map == null) {
        throw Exception('Failed to read imported skin');
      }
      final skin = Skin.fromJson(map);

      return SkinResponse.success(
        message: 'Skin imported successfully',
        skin: skin,
      );
    } catch (e) {
      print('[SkinService] Failed to import skin: $e');
      return SkinResponse.error('Failed to import skin: $e');
    }
  }
}
