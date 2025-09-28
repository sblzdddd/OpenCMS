import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/skin/skin.dart';
import '../../data/models/skin/skin_response.dart';

/// Service for managing skin configurations and image files
class SkinService {
  static const String _skinsKey = 'app_skins';
  static const String _activeSkinKey = 'active_skin_id';
  
  final ImagePicker _imagePicker = ImagePicker();

  /// Initialize the skin service
  Future<void> initialize() async {
  }

  /// Get all available skins
  Future<SkinResponse> getAllSkins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final skinsJson = prefs.getStringList(_skinsKey) ?? [];
      
      final skins = skinsJson
          .map((json) => Skin.fromJson(jsonDecode(json)))
          .toList();

      // Sort skins: active first, then by creation date
      skins.sort((a, b) {
        if (a.isActive && !b.isActive) return -1;
        if (!a.isActive && b.isActive) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

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
      
      if (activeSkinId == null) {
        // Return default skin if no active skin is set
        return _getDefaultSkin();
      }

      final allSkinsResponse = await getAllSkins();
      if (!allSkinsResponse.success) {
        return allSkinsResponse;
      }

      final activeSkin = allSkinsResponse.skins?.firstWhere(
        (skin) => skin.id == activeSkinId,
        orElse: () => _createDefaultSkin(),
      );

      return SkinResponse.success(skin: activeSkin);
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

  /// Set a skin as active
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

      // Deactivate all other skins
      final updatedSkins = allSkinsResponse.skins!.map((s) {
        return s.copyWith(isActive: s.id == skinId);
      }).toList();

      await _saveSkinsToStorage(updatedSkins);

      // Save active skin ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeSkinKey, skinId);

      return SkinResponse.success(
        message: 'Skin activated successfully',
        skin: skin,
      );
    } catch (e) {
      return SkinResponse.error('Failed to set active skin: $e');
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

      return SkinResponse.success(
        message: 'Image removed successfully',
        skin: updatedSkin,
      );
    } catch (e) {
      return SkinResponse.error('Failed to remove image: $e');
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

  /// Get default skin
  SkinResponse _getDefaultSkin() {
    return SkinResponse.success(skin: _createDefaultSkin());
  }

  /// Create default skin
  Skin _createDefaultSkin() {
    return Skin(
      id: 'default',
      name: 'Default',
      author: 'Default',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDefault: true,
      isActive: true,
    );
  }
}
