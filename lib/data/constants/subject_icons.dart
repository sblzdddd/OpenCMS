import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Provides icon lookup for subjects based on name aliases first, then code.
class SubjectIconConstants {
  // Unified category mapping - groups related subjects and maps to icons
  static const Map<String, IconData> _categoryToIcon = {
    // Sciences
    'physics': Symbols.specific_gravity_rounded,
    'chemistry': Symbols.experiment_rounded,
    'biology': Symbols.biotech_rounded,
    'science': Symbols.science_rounded,

    // Mathematics
    'mathematics': Symbols.calculate_rounded,
    'further_math': Symbols.functions_rounded,

    // English / Languages
    'literature': Symbols.menu_book_rounded,
    'language': Symbols.language_rounded,
    'chinese': Symbols.language_chinese_cangjie_rounded,
    'japanese': Symbols.language_japanese_kana_rounded,
    'spanish': Symbols.language_spanish_rounded,

    // Technology
    'computer_science': Symbols.dns_rounded,

    // Social Sciences / Business
    'economics': Symbols.trending_up_rounded,
    'business': Symbols.business_center_rounded,
    'accounting': Symbols.request_quote_rounded,
    'geography': Symbols.public_rounded,
    'history': Symbols.auto_stories_rounded,
    'psychology': Symbols.psychology_rounded,
    'sociology': Symbols.groups_3_rounded,

    // Arts / PE
    'art': Symbols.palette_rounded,
    'design': Symbols.draw_rounded,
    'music': Symbols.music_note_rounded,
    'pe': Symbols.sports_gymnastics_rounded,

    // General
    'form_time': Symbols.badge_rounded,
    'pastoral': Symbols.volunteer_activism_rounded,
    'tutor': Symbols.co_present_rounded,
    'rpq': Symbols.emoji_objects_rounded,
    'evening_study': Symbols.local_library_rounded
  };

  // Map of lowercase alias substring -> category key
  static const Map<String, String> _aliasToCategory = {
    // Sciences
    'physics': 'physics',
    'chemistry': 'chemistry',
    'biology': 'biology',
    'science': 'science',

    // Mathematics
    'mathematics': 'mathematics',
    'further math': 'further_math',
    'further mathematics': 'further_math',

    // English / Languages
    'literature': 'literature',
    'language': 'language',
    'chinese': 'chinese',
    'japanese': 'japanese',
    'spanish': 'spanish',

    // Technology
    'computer science': 'computer_science',
    'computer_science': 'computer_science',

    // Social Sciences / Business
    'economics': 'economics',
    'business': 'business',
    'accounting': 'accounting',
    'geography': 'geography',
    'history': 'history',
    'psychology': 'psychology',
    'sociology': 'sociology',
    'global perspectives': 'language',

    // Arts / PE
    'art': 'art',
    'design': 'design',
    'music': 'music',
    'pe': 'pe',
    'physical education': 'pe',

    // General
    'form time': 'form_time',
    'pastoral': 'pastoral',
    'pshe': 'pastoral',
    'tutor': 'tutor',
    'rpq': 'rpq',
    'evening study': 'evening_study'
  };

  // Map of uppercase code substring -> category key
  static const Map<String, String> _codeToCategory = {
    // Sciences
    'PHY': 'physics',
    'CHE': 'chemistry',
    'CHM': 'chemistry',
    'BIO': 'biology',
    'SCI': 'science',

    // Mathematics
    'MAT': 'mathematics',
    'MATH': 'mathematics',
    'FM': 'further_math',
    'FURTHER': 'further_math',

    // English / Languages
    'ENG': 'literature',
    'LIT': 'literature',
    'LAN': 'language',
    'CHN': 'chinese',
    'CHI': 'chinese',
    'JAP': 'japanese',
    'SPA': 'spanish',
    
    // Technology
    'CPU': 'computer_science',
    'CS': 'computer_science',

    // Social Sciences / Business
    'ECO': 'economics',
    'BUS': 'business',
    'ACC': 'accounting',
    'GEO': 'geography',
    'HIS': 'history',
    'PSY': 'psychology',
    'SOC': 'sociology',
    'GP': 'language',

    // Arts / PE
    'ART': 'art',
    'DES': 'design',
    'MUS': 'music',
    'PE': 'pe',

    // General
    'FORM': 'form_time',
    'TUTOR': 'tutor',
    'PSHE': 'pastoral',
    'RPQ': 'rpq',
    'ES': 'evening_study'
  };

  static const IconData _defaultIcon = Symbols.school_rounded;

  /// Returns an icon for the given subject.
  /// Priority: subject name/aliases (exact match, case-insensitive) -> code (exact match, case-insensitive) -> 
  /// subject name/aliases (substring match, case-insensitive) -> code (substring match, case-insensitive) -> default.
  static IconData getIconForSubject({required String subjectName, required String code, IconData? placeholder = Symbols.school_rounded}) {
    final name = subjectName.toLowerCase();
    final upperCode = code.toUpperCase();
    
    // Try exact matches first
    if (_aliasToCategory.containsKey(name)) {
      final category = _aliasToCategory[name]!;
      return _categoryToIcon[category] ?? (placeholder ?? _defaultIcon);
    }
    
    if (_codeToCategory.containsKey(upperCode)) {
      final category = _codeToCategory[upperCode]!;
      return _categoryToIcon[category] ?? (placeholder ?? _defaultIcon);
    }
    
    // Try substring matches
    for (final entry in _aliasToCategory.entries) {
      if (name.contains(entry.key)) {
        final category = entry.value;
        return _categoryToIcon[category] ?? (placeholder ?? _defaultIcon);
      }
    }
    
    for (final entry in _codeToCategory.entries) {
      if (upperCode.contains(entry.key)) {
        final category = entry.value;
        return _categoryToIcon[category] ?? (placeholder ?? _defaultIcon);
      }
    }
    
    // Try code as lowercase for alias matching
    final codeName = code.toLowerCase();
    for (final entry in _aliasToCategory.entries) {
      if (codeName.contains(entry.key)) {
        final category = entry.value;
        return _categoryToIcon[category] ?? (placeholder ?? _defaultIcon);
      }
    }
    
    // Try subject name as uppercase for code matching
    final nameCode = subjectName.toUpperCase();
    for (final entry in _codeToCategory.entries) {
      if (nameCode.contains(entry.key)) {
        final category = entry.value;
        return _categoryToIcon[category] ?? (placeholder ?? _defaultIcon);
      }
    }

    return placeholder ?? _defaultIcon;
  }
}


