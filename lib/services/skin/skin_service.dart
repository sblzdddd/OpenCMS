import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/skin/skin.dart';
import '../../data/models/skin/skin_image.dart';
import '../../data/models/skin/skin_response.dart';

/// Service for managing skin configurations and image files
class SkinService extends ChangeNotifier {
  static const String _skinsKey = 'app_skins';
  static const String _activeSkinKey = 'active_skin_id';
  
  final ImagePicker _imagePicker = ImagePicker();
  
  /// Current active skin
  Skin? _activeSkin;
  
  /// Singleton instance
  static final SkinService _instance = SkinService._internal();
  
  /// Private constructor
  SkinService._internal();
  
  /// Get the singleton instance
  static SkinService get instance => _instance;
  
  /// Get the current active skin
  Skin? get activeSkin => _activeSkin;

  /// Initialize the skin service
  Future<void> initialize() async {
  }

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
        orElse: () => throw Exception('Skin not found'),
      );

      return SkinResponse.success(skin: skin);
    } catch (e) {
      return SkinResponse.error('Failed to get skin by id: $e');
    }
  }

  /// Get all available skins (excluding default skin)
  Future<SkinResponse> getAllSkins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final skinsJson = prefs.getStringList(_skinsKey) ?? [];
      final activeSkinId = prefs.getString(_activeSkinKey);
      
      final skins = skinsJson
          .map((json) => Skin.fromJson(jsonDecode(json)))
          .where((skin) => !skin.isDefault) // Exclude default skin from stored skins
          .toList();

      // Ensure only one skin is active at a time
      bool hasActiveSkin = false;
      if (activeSkinId != null && activeSkinId != 'default') {
        for (var skin in skins) {
          if (skin.id == activeSkinId) {
            skin.isActive = true;
            hasActiveSkin = true;
          } else {
            skin.isActive = false;
          }
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
    } catch (e) {
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

      final allSkinsResponse = await getAllSkins();
      if (!allSkinsResponse.success) {
        return allSkinsResponse;
      }

      final activeSkin = allSkinsResponse.skins?.firstWhere(
        (skin) => skin.id == activeSkinId,
        orElse: () => createDefaultSkin(),
      );

      _activeSkin = activeSkin?.copyWith(isActive: true);
      notifyListeners();
      return SkinResponse.success(skin: _activeSkin);
    } catch (e) {
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
      final skin = Skin(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        author: author,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final response = await _saveSkin(skin);
      if (response.success) {
        return SkinResponse.success(
          message: 'Skin created successfully',
          skin: skin,
        );
      }
      return response;
    } catch (e) {
      return SkinResponse.error('Failed to create skin: $e');
    }
  }

  /// Update an existing skin
  Future<SkinResponse> updateSkin(Skin skin) async {
    try {
      final updatedSkin = skin.copyWith(updatedAt: DateTime.now());
      return await _saveSkin(updatedSkin);
    } catch (e) {
      return SkinResponse.error('Failed to update skin: $e');
    }
  }

  /// Delete a skin
  Future<SkinResponse> deleteSkin(String skinId) async {
    try {
      final allSkinsResponse = await getAllSkins();
      if (!allSkinsResponse.success) {
        return allSkinsResponse;
      }

      final skins = allSkinsResponse.skins ?? [];
      final skinToDelete = skins.firstWhere(
        (skin) => skin.id == skinId,
        orElse: () => throw Exception('Skin not found'),
      );

      // Don't allow deleting the default skin
      if (skinToDelete.isDefault) {
        return SkinResponse.error('Cannot delete the default skin');
      }

      // Delete associated image files
      await skinToDelete.onDelete();

      // Remove from storage
      final updatedSkins = skins.where((skin) => skin.id != skinId).toList();
      await _saveSkinsToStorage(updatedSkins);

      // If this was the active skin, set default as active
      final prefs = await SharedPreferences.getInstance();
      final activeSkinId = prefs.getString(_activeSkinKey);
      if (activeSkinId == skinId) {
        await prefs.remove(_activeSkinKey);
      }

      return SkinResponse.success(message: 'Skin deleted successfully');
    } catch (e) {
      return SkinResponse.error('Failed to delete skin: $e');
    }
  }

  /// Set a skin as active (only one skin can be active at a time)
  Future<SkinResponse> setActiveSkin(String skinId) async {
    try {
      final allSkinsResponse = await getAllSkins();
      if (!allSkinsResponse.success) {
        return allSkinsResponse;
      }

      final skin = allSkinsResponse.skins?.firstWhere(
        (skin) => skin.id == skinId,
        orElse: () => throw Exception('Skin not found'),
      );

      // Deactivate all other skins and activate the selected one
      final updatedSkins = allSkinsResponse.skins!.map((s) {
        return s.copyWith(isActive: s.id == skinId);
      }).toList();

      await _saveSkinsToStorage(updatedSkins);

      // Save active skin ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeSkinKey, skinId);

      // Update cached active skin and notify listeners
      _activeSkin = skin?.copyWith(isActive: true);
      notifyListeners();

      return SkinResponse.success(
        message: 'Skin activated successfully',
        skin: _activeSkin,
      );
    } catch (e) {
      return SkinResponse.error('Failed to set active skin: $e');
    }
  }

  /// Clear the active skin (reset to default)
  Future<SkinResponse> clearActiveSkin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeSkinKey, 'default');

      // Deactivate all skins in storage
      final allSkinsResponse = await getAllSkins();
      if (allSkinsResponse.success) {
        final updatedSkins = allSkinsResponse.skins!.map((s) {
          return s.copyWith(isActive: false);
        }).toList();
        await _saveSkinsToStorage(updatedSkins);
      }

      // Update cached active skin to default and notify listeners
      final defaultSkin = createDefaultSkin();
      _activeSkin = defaultSkin;
      notifyListeners();

      return SkinResponse.success(
        message: 'Default skin is now active',
        skin: defaultSkin,
      );
    } catch (e) {
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
        return SkinResponse.error('No image selected');
      }

      return await setSkinImage(skinId: skinId, key: key, imagePath: pickedFile.path);
    } catch (e) {
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
      final allSkinsResponse = await getAllSkins();
      if (!allSkinsResponse.success) {
        return allSkinsResponse;
      }

      final skins = allSkinsResponse.skins ?? [];
      final skinIndex = skins.indexWhere((skin) => skin.id == skinId);
      
      if (skinIndex == -1) {
        return SkinResponse.error('Skin not found');
      }

      final skin = skins[skinIndex];
      
      // Update skin with new image path using generic method
      final updatedSkin = await skin.setImagePath(key, imagePath);
      if (updatedSkin == null) {
        return SkinResponse.error('Failed to set image');
      }

      // Update skin in storage
      skins[skinIndex] = updatedSkin;
      await _saveSkinsToStorage(skins);

      // Update cached active skin if this is the active skin
      if (_activeSkin?.id == skinId) {
        _activeSkin = updatedSkin;
        notifyListeners();
      }

      return SkinResponse.success(
        message: 'Image set successfully',
        skin: updatedSkin,
      );
    } catch (e) {
      return SkinResponse.error('Failed to set image: $e');
    }
  }

  /// Remove an image from a skin
  Future<SkinResponse> removeSkinImage({
    required String skinId,
    required String key,
  }) async {
    try {
      final allSkinsResponse = await getAllSkins();
      if (!allSkinsResponse.success) {
        return allSkinsResponse;
      }

      final skins = allSkinsResponse.skins ?? [];
      final skinIndex = skins.indexWhere((skin) => skin.id == skinId);
      
      if (skinIndex == -1) {
        return SkinResponse.error('Skin not found');
      }

      final skin = skins[skinIndex];
      

      // Update skin to remove image path using generic method
      final updatedSkin = await skin.setImagePath(key, null);
      if (updatedSkin == null) {
        return SkinResponse.error('Failed to remove image');
      }

      skins[skinIndex] = updatedSkin;
      await _saveSkinsToStorage(skins);

      // Update cached active skin if this is the active skin
      if (_activeSkin?.id == skinId) {
        _activeSkin = updatedSkin;
        notifyListeners();
      }

      return SkinResponse.success(
        message: 'Image removed successfully',
        skin: updatedSkin,
      );
    } catch (e) {
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
      final allSkinsResponse = await getAllSkins();
      if (!allSkinsResponse.success) {
        return allSkinsResponse;
      }

      final skins = allSkinsResponse.skins ?? [];
      final skinIndex = skins.indexWhere((skin) => skin.id == skinId);
      
      if (skinIndex == -1) {
        return SkinResponse.error('Skin not found');
      }

      final skin = skins[skinIndex];
      
      // Create a new skin with updated image data
      final updatedImageDataMap = Map<String, SkinImageData>.from(skin.imageData);
      updatedImageDataMap[imageKey] = updatedImageData;
      
      final updatedSkin = skin.copyWith(
        imageData: updatedImageDataMap,
        updatedAt: DateTime.now(),
      );

      // Update skin in storage
      skins[skinIndex] = updatedSkin;
      await _saveSkinsToStorage(skins);

      // Update cached active skin if this is the active skin
      if (_activeSkin?.id == skinId) {
        _activeSkin = updatedSkin;
        notifyListeners();
      }

      return SkinResponse.success(
        message: 'Image data updated successfully',
        skin: updatedSkin,
      );
    } catch (e) {
      return SkinResponse.error('Failed to update image data: $e');
    }
  }

  /// Save a skin to storage
  Future<SkinResponse> _saveSkin(Skin skin) async {
    try {
      final allSkinsResponse = await getAllSkins();
      if (!allSkinsResponse.success) {
        return allSkinsResponse;
      }

      final skins = allSkinsResponse.skins ?? [];
      final existingIndex = skins.indexWhere((s) => s.id == skin.id);
      
      if (existingIndex >= 0) {
        skins[existingIndex] = skin;
      } else {
        skins.add(skin);
      }

      await _saveSkinsToStorage(skins);
      return SkinResponse.success(skin: skin);
    } catch (e) {
      return SkinResponse.error('Failed to save skin: $e');
    }
  }

  /// Save all skins to storage
  Future<void> _saveSkinsToStorage(List<Skin> skins) async {
    final prefs = await SharedPreferences.getInstance();
    final skinsJson = skins.map((skin) => jsonEncode(skin.toJson())).toList();
    await prefs.setStringList(_skinsKey, skinsJson);
  }


  /// Create default skin (placeholder - not stored in skins list)
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
}
