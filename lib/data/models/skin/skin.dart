import 'skin_image.dart';
import '../../constants/skin_constants.dart';
import '../../../services/skin/skin_file_manager.dart';

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
  }) : imageData = imageData ?? Map<String, SkinImageData>.from(defaultImageData);

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
      imageData: imageData ?? this.imageData,
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
  Map<String, dynamic> toJson() {
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
    
    // Only serialize imageData if it differs from default
    final hasNonDefaultImageData = imageData.entries.any((entry) {
      final defaultData = defaultImageData[entry.key];
      return defaultData == null || entry.value != defaultData;
    });
    
    if (hasNonDefaultImageData) {
      json['imageData'] = imageData.map((key, value) => MapEntry(key, value.toJson()));
    }
    
    return json;
  }

  /// Create skin from JSON
  factory Skin.fromJson(Map<String, dynamic> json) {
    Map<String, SkinImageData> imageData;
    if (json.containsKey('imageData') && json['imageData'] != null) {
      print('Skin.fromJson: Using new imageData format');
      try {
        imageData = Map<String, SkinImageData>.from(
          (json['imageData'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, SkinImageData.fromJson(value as Map<String, dynamic>))
          )
        );
      } catch (e) {
        print('Skin.fromJson: Error parsing imageData: $e');
        imageData = Map<String, SkinImageData>.from(defaultImageData);
      }
    } else {
      print('Skin.fromJson: No image data found, using default');
      imageData = Map<String, SkinImageData>.from(defaultImageData);
    }
    
    return Skin(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageData: imageData,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch),
      author: json['author'] as String? ?? '',
      homepage: json['homepage'] as String? ?? '',
      version: json['version'] as String? ?? '1.0',
      skinVersion: json['skinVersion'] as String? ?? '1.0',
    );
  }
  
  /// Check if skin has an image of the specified type
  bool hasImage(String key) {
    return imageData[key]?.hasImage ?? false;
  }

  /// Check if image file exists for the specified type
  Future<bool> imageExists(String key) async {
    final path = imageData[key]?.imagePath;
    return SkinFileManager.imageExists(path);
  }

  Future<String> getSkinDirectoryPath() async {
    return SkinFileManager.getSkinDirectoryPath(id);
  }
  
  /// Copy image to skins directory
  Future<String> copyImageToSkinsDirectory(String sourcePath, String key) async {
    return SkinFileManager.copyImageToSkinsDirectory(sourcePath, id, key);
  }

  Future<Skin?> setImagePath(String key, String? imagePath) async {
    if (imageData[key] == null) {
      return null;
    }
    final oldPath = imageData[key]?.imagePath;
    await SkinFileManager.deleteFileIfExists(oldPath, id);
    
    if (imagePath != null) {
      imagePath = await copyImageToSkinsDirectory(imagePath, key);
    }
    imageData[key] = imageData[key]!.copyWith(imagePath: imagePath);
    return this;
  }

  String? getImagePath(String key) {
    return imageData[key]?.imagePath;
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
