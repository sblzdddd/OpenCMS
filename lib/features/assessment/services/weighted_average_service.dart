import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:opencms/features/API/storage/secure_storage_base.dart';
import '../models/assessment_models.dart';

final logger = Logger('WeightedAverageService');

class WeightedAverageService extends ChangeNotifier {
  static final WeightedAverageService _instance = WeightedAverageService._internal();

  factory WeightedAverageService() => _instance;

  WeightedAverageService._internal();

  late SecureStorageBase _storage;
  final Map<String, int> _weights = {};
  final Map<String, Timer> _debounceTimers = {};
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      // Using prefix 'weight_' for our storage namespace
      _storage = SecureStorageBase(const FlutterSecureStorage(), 'weight_');
      await _storage.init(true, false);
      _initialized = true;
      notifyListeners();
    } catch (e) {
      logger.severe('Failed to initialize WeightedAverageService: $e');
    }
  }

  String _getKey(int subjectId, Assessment assessment) {
    // Composite key: subjectId_date_title
    // sanitizing title to avoid special char issues in keys if necessary, 
    // but SecureStorage handles string keys.
    // We should stick to a consistent format.
    return '${subjectId}_${assessment.date}_${assessment.title}';
  }

  Future<int> getWeight(int subjectId, Assessment assessment) async {
    if (!_initialized) await init();
    
    final key = _getKey(subjectId, assessment);
    if (_weights.containsKey(key)) {
      return _weights[key]!;
    }

    final storedValue = await _storage.read(key);
    if (storedValue != null) {
      final weight = int.tryParse(storedValue) ?? 0; // Default to 0%
      _weights[key] = weight;
      return weight;
    }

    return 0; // Default weight
  }

  Future<void> setWeight(int subjectId, Assessment assessment, int weight) async {
    if (!_initialized) await init();

    final key = _getKey(subjectId, assessment);
    
    // Update memory cache and notify UI immediately
    _weights[key] = weight;
    notifyListeners();

    // Debounce write operation to avoid file lock issues
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(const Duration(milliseconds: 1000), () async {
      try {
        await _storage.write(key, weight.toString());
      } catch (e) {
        logger.warning('Failed to write weight to storage: $e');
      }
      _debounceTimers.remove(key);
    });
  }

  Future<double?> calculateWeightedAverage(SubjectAssessment subject) async {
    if (!_initialized) await init();

    double totalWeightedScore = 0;
    double totalMaxWeight = 0;
    bool hasAnyScore = false;

    for (final assessment in subject.assessments) {
      final percentage = assessment.percentageScore ?? 0.0;
      // Treat as valid score even if null (parsed as 0), if it has weight assignment logic or just existence
      hasAnyScore = true;
      final weight = await getWeight(subject.id, assessment);
      
      totalWeightedScore += percentage * weight;
      totalMaxWeight += weight;
    }

    if (!hasAnyScore || totalMaxWeight == 0) return null;

    return totalWeightedScore / totalMaxWeight;
  }
  
  /// Helper to check current used weight sum for a subject (useful for UI validation if we wanted to enforce 100% total)
  Future<int> getTotalWeightUsed(SubjectAssessment subject) async {
     int total = 0;
     for (final assessment in subject.assessments) {
        total += await getWeight(subject.id, assessment);
     }
     return total;
  }

  Future<void> clearAll() async {
    if (!_initialized) await init();
    _weights.clear();
    await _storage.clear();
    notifyListeners();
  }
}
