import 'package:flutter/rendering.dart';

import 'skin_image.dart';
import 'skin_constants.dart';
import '../services/skin_file_manager.dart';
import 'skin_image_type.dart';

/// Configuration for skin customization elements
class Skin {
  String id;
  String name;
  String description;
  String author;
  String homepage;
  String version;
  String skinVersion;
  Map<String, SkinImageData> imageData;
  DateTime createdAt;
  DateTime updatedAt;

  bool isDefault;
  bool isActive;

  Skin({
    required this.id,
    required this.name,
    this.description = '',
    required this.author,
    this.homepage = '',
    this.version = '1.0',
    this.skinVersion = '1.0',
    required this.createdAt,
    required this.updatedAt,
    Map<String, SkinImageData>? imageData,
    this.isDefault = false,
    this.isActive = false,
  }) : imageData =
           imageData ?? Map<String, SkinImageData>.from(defaultImageData);

  /// Create a copy of this skin with updated fields
  Skin copyWith({
    String? id,
    String? name,
    String? description,
    Map<String, SkinImageData>? imageData,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? author,
    String? homepage,
    String? version,
    String? skinVersion,
    bool? isDefault,
    bool? isActive,
  }) {
    return Skin(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageData: imageData ?? Map<String, SkinImageData>.from(this.imageData),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      homepage: homepage ?? this.homepage,
      version: version ?? this.version,
      skinVersion: skinVersion ?? this.skinVersion,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Convert skin to JSON for storage
  Map<String, dynamic> toJson({bool useRelativePaths = false}) {
    final json = <String, dynamic>{
      'id': id,
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'author': author,
    };

    // Only serialize non-default values
    if (description.isNotEmpty) {
      json['description'] = description;
    }

    if (homepage.isNotEmpty) {
      json['homepage'] = homepage;
    }

    if (version != '1.0') {
      json['version'] = version;
    }

    if (skinVersion != '1.0') {
      json['skinVersion'] = skinVersion;
    }

    if (isDefault) {
      json['isDefault'] = isDefault;
    }

    if (isActive) {
      json['isActive'] = isActive;
    }

    // Serialize only entries that differ from defaults
    final Map<String, dynamic> diffImageData = {};
    for (final entry in imageData.entries) {
      final defaultData = defaultImageData[entry.key];
      if (defaultData == null || entry.value != defaultData) {
        final valueJson = entry.value.toJson(useRelativePath: useRelativePaths);
        if (valueJson.isNotEmpty) {
          diffImageData[entry.key] = valueJson;
        }
      }
    }
    if (diffImageData.isNotEmpty) {
      json['imageData'] = diffImageData;
    }

    return json;
  }

  /// Create skin from JSON
  factory Skin.fromJson(Map<String, dynamic> json) {
    Map<String, SkinImageData> imageData;
    if (json.containsKey('imageData') && json['imageData'] != null) {
      try {
        final Map<String, dynamic> raw =
            (json['imageData'] as Map<String, dynamic>);
        // Merge with defaults so that type and defaults come from defaultImageData
        imageData = Map<String, SkinImageData>.fromEntries(
          defaultImageData.entries.map((defaultEntry) {
            final key = defaultEntry.key;
            final defaults = defaultEntry.value;
            final valueJson = raw[key];
            if (valueJson is Map<String, dynamic>) {
              return MapEntry(
                key,
                SkinImageData.fromJsonWithDefaults(valueJson, defaults),
              );
            }
            return MapEntry(key, defaults);
          }),
        );
        // Preserve any unknown keys by parsing them with background type as fallback
        for (final extra in raw.entries) {
          if (!imageData.containsKey(extra.key) &&
              extra.value is Map<String, dynamic>) {
            final defaults = const SkinImageData();
            imageData[extra.key] = SkinImageData.fromJsonWithDefaults(
              extra.value as Map<String, dynamic>,
              defaults,
            );
          }
        }
      } catch (e) {
        debugPrint('[Skin] Error parsing imageData: $e');
        imageData = Map<String, SkinImageData>.from(defaultImageData);
      }
    } else {
      debugPrint('[Skin] No image data found, using default');
      imageData = Map<String, SkinImageData>.from(defaultImageData);
    }

    return Skin(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageData: imageData,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        json['updatedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      author: json['author'] as String? ?? '',
      homepage: json['homepage'] as String? ?? '',
      version: json['version'] as String? ?? '1.0',
      skinVersion: json['skinVersion'] as String? ?? '1.0',
      isDefault: false,
      isActive: false,
    );
  }

  /// Check if skin has an image of the specified type
  bool hasImage(String key) {
    return imageData[key]?.hasImage ?? false;
  }

  bool hasAnyBGImage() {
    return imageData.values.any(
      (image) => image.type == SkinImageType.background && image.hasImage,
    );
  }

  /// Check if image file exists for the specified type
  Future<bool> imageExists(String key) async {
    final path = imageData[key]?.imagePath;
    return SkinFileManager.imageExists(path);
  }

  Future<String> getSkinDirectoryPath() async {
    return SkinFileManager.getSkinDirectoryPath(id);
  }

  Future<Skin?> setImagePath(String key, String? imagePath) async {
    final oldPath = imageData[key]?.imagePath;
    await SkinFileManager.deleteFileIfExists(oldPath, id);

    if (imagePath != null) {
      imagePath = await SkinFileManager.copyImageToSkinsDirectory(
        imagePath,
        id,
        key,
      );
    }
    imageData[key] = imageData[key]!.copyWith(imagePath: imagePath);
    updatedAt = DateTime.now();
    await SkinFileManager.writeSkinJsonMap(id, toJson());
    return this;
  }

  /// Update a specific image data entry and persist to skin.json
  Future<Skin?> setImageData(String key, SkinImageData newData) async {
    imageData[key] = newData;
    updatedAt = DateTime.now();
    await SkinFileManager.writeSkinJsonMap(id, toJson());
    return this;
  }

  Future<void> onDelete() async {
    await SkinFileManager.deleteSkinFiles(imageData, id);
  }

  @override
  String toString() {
    return 'Skin(id: $id, name: $name, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Skin && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
