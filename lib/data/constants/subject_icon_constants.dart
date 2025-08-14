import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Provides icon lookup for subjects based on name aliases first, then code.
class SubjectIconConstants {
  // Map of lowercase alias substring -> icon
  static const Map<String, IconData> _aliasToIcon = {
    // Sciences
    'physics': Symbols.specific_gravity_rounded,
    'chemistry': Symbols.experiment_rounded,
    'biology': Symbols.biotech_rounded,
    'science': Symbols.science_rounded,

    // Mathematics
    'mathematics': Symbols.calculate_rounded,
    'further math': Symbols.functions_rounded,
    'further mathematics': Symbols.functions_rounded,

    // English / Languages
    'english': Symbols.menu_book_rounded,
    'literature': Symbols.menu_book_rounded,
    'language': Symbols.language_rounded,
    'chinese': Symbols.language_chinese_cangjie_rounded,
    'japanese': Symbols.language_japanese_kana_rounded,
    'spanish': Symbols.language_spanish_rounded,

    // Technology
    'computer science': Symbols.dns_rounded,
    'computing': Symbols.dns_rounded,
    'ict': Symbols.memory_rounded,
    'information technology': Symbols.memory_rounded,

    // Social Sciences / Business
    'economics': Symbols.trending_up_rounded,
    'business': Symbols.business_center_rounded,
    'accounting': Symbols.request_quote_rounded,
    'geography': Symbols.public_rounded,
    'history': Symbols.auto_stories_rounded,
    'psychology': Symbols.psychology_rounded,
    'sociology': Symbols.groups_3_rounded,
    'global perspectives': Symbols.language_rounded,

    // Arts / PE
    'art': Symbols.palette_rounded,
    'design': Symbols.draw_rounded,
    'music': Symbols.music_note_rounded,
    'pe': Symbols.sports_gymnastics_rounded,
    'physical education': Symbols.sports_gymnastics_rounded,

    // General
    'form time': Symbols.badge_rounded,
    'pastoral': Symbols.volunteer_activism_rounded,
    'pshe': Symbols.volunteer_activism_rounded,
    'tutor': Symbols.co_present_rounded,
    'rpq': Symbols.emoji_objects_rounded,
    'evening study': Symbols.local_library_rounded
  };

  // Map of uppercase code substring -> icon
  static const Map<String, IconData> _codeToIcon = {
    // Sciences
    'PHY': Symbols.specific_gravity_rounded,
    'CHE': Symbols.experiment_rounded,
    'CHM': Symbols.experiment_rounded,
    'BIO': Symbols.biotech_rounded,
    'SCI': Symbols.specific_gravity_rounded,

    // Mathematics
    'MAT': Symbols.calculate_rounded,
    'MATH': Symbols.calculate_rounded,
    'FM': Symbols.functions_rounded,
    'FURTHER': Symbols.functions_rounded,

    // English / Languages
    'ENG': Symbols.menu_book_rounded,
    'LIT': Symbols.menu_book_rounded,
    'LAN': Symbols.language_rounded,
    'CHN': Symbols.language_chinese_cangjie_rounded,
    'CHI': Symbols.language_chinese_cangjie_rounded,
    'JAP': Symbols.language_japanese_kana_rounded,
    'SPA': Symbols.language_spanish_rounded,
    
    // Technology
    'CPU': Symbols.dns_rounded,
    'CS': Symbols.dns_rounded,
    'ICT': Symbols.dns_rounded,

    // Social Sciences / Business
    'ECO': Symbols.trending_up_rounded,
    'BUS': Symbols.business_center_rounded,
    'ACC': Symbols.request_quote_rounded,
    'GEO': Symbols.public_rounded,
    'HIS': Symbols.auto_stories_rounded,
    'PSY': Symbols.psychology_rounded,
    'SOC': Symbols.groups_3_rounded,
    'GP': Symbols.language_rounded,

    // Arts / PE
    'ART': Symbols.palette_rounded,
    'DES': Symbols.draw_rounded,
    'MUS': Symbols.music_note_rounded,
    'PE': Symbols.sports_gymnastics_rounded,

    // General
    'FORM': Symbols.badge_rounded,
    'TUTOR': Symbols.co_present_rounded,
    'PSHE': Symbols.volunteer_activism_rounded,
    'RPQ': Symbols.emoji_objects_rounded,
    'ES': Symbols.local_library_rounded
  };

  static const IconData _defaultIcon = Symbols.school_rounded;

  /// Returns an icon for the given subject.
  /// Priority: subject name/aliases (substring match, case-insensitive) -> code (substring match, case-insensitive) -> default.
  static IconData getIconForSubject({required String subjectName, required String code}) {
    final name = subjectName.toLowerCase();
    for (final entry in _aliasToIcon.entries) {
      if (name == entry.key) {
        return entry.value;
      }
    }

    final upperCode = code.toUpperCase();
    for (final entry in _codeToIcon.entries) {
      if (upperCode == entry.key) {
        return entry.value;
      }
    }

    final nameCode = subjectName.toUpperCase();
    for (final entry in _codeToIcon.entries) {
      if (nameCode.contains(entry.key)) {
        return entry.value;
      }
    }

    final codeName = code.toLowerCase();
    for (final entry in _aliasToIcon.entries) {
      if (codeName.contains(entry.key)) {
        return entry.value;
      }
    }

    return _defaultIcon;
  }
}


