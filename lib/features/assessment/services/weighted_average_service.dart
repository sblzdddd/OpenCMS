import 'dart:async';
import 'package:flutter/material.dart';

import 'package:logging/logging.dart';
import 'package:opencms/di/locator.dart';
import 'package:opencms/features/API/storage/secure_storage_base.dart';
import 'package:opencms/features/API/storage/storage_client.dart';
import 'package:opencms/features/auth/services/login_state.dart';
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
    logger.info('Initializing WeightedAverageService');
    try {
      // Using prefix 'weight_' for our storage namespace
      _storage = SecureStorageBase(StorageClient.instance, 'weight_');
      await _storage.init(true, false);
      _initialized = true;
      notifyListeners();
    } catch (e) {
      logger.severe('Failed to initialize WeightedAverageService: $e');
    }
  }

  String _getKey(int subjectId, Assessment assessment) {
    // although subject assessments' weights are the same, account separation should still be
    // done to provide a safer experience in multi-account scenarios
    final userName = di<LoginState>().currentUsername;
    final key = '${userName}_${subjectId}_${assessment.date}_${assessment.title}';
    logger.fine('Generating key: $key');
    return key;
  }

  Future<int> getWeight(int subjectId, Assessment assessment) async {
    if (!_initialized) await init();
    logger.info('Getting weight for subjectId: $subjectId, assessment: ${assessment.title}');
    
    final key = _getKey(subjectId, assessment);
    if (_weights.containsKey(key)) {
      logger.fine('Weight found in cache for key: $key');
      return _weights[key]!;
    }
    logger.fine('Weight not found in cache, checking storage for key: $key');

    final storedValue = await _storage.read(key);
    if (storedValue != null) {
      logger.fine('Weight found in storage for key: $key, value: $storedValue');
      // default to 0 if parsing fails
      final weight = int.tryParse(storedValue) ?? 0;
      _weights[key] = weight;
      return weight;
    }
    logger.fine('No weight found for key: $key, defaulting to 0');

    return 0;
  }

  Future<void> setWeight(int subjectId, Assessment assessment, int weight) async {
    if (!_initialized) await init();
    logger.info('Setting weight for subjectId: $subjectId, assessment: ${assessment.title}, weight: $weight');

    final key = _getKey(subjectId, assessment);
    
    // Update memory cache and notify UI immediately
    _weights[key] = weight;
    notifyListeners();

    // Debounce write operation to avoid file lock issues
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(const Duration(milliseconds: 1000), () async {
      try {
        logger.fine('Writing weight to storage after debounce for key: $key, weight: $weight');
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
      // Treat as valid score even if null (parsed as 0)
      hasAnyScore = true;
      final weight = await getWeight(subject.id, assessment);
      
      totalWeightedScore += percentage * weight;
      totalMaxWeight += weight;
    }

    if (!hasAnyScore || totalMaxWeight == 0) return null;

    return totalWeightedScore / totalMaxWeight;
  }
  
  /// Helper to check current used weight sum for a subject
  Future<int> getTotalWeightUsed(SubjectAssessment subject) async {
     int total = 0;
     for (final assessment in subject.assessments) {
        total += await getWeight(subject.id, assessment);
     }
     return total;
  }

  Future<void> resetSubjectWeights(SubjectAssessment subject) async {
    if (!_initialized) await init();
    logger.info('Resetting weights for subject: ${subject.subject}');

    for (final assessment in subject.assessments) {
      final key = _getKey(subject.id, assessment);

      // Remove from memory
      _weights.remove(key);

      // Cancel any pending writes
      _debounceTimers[key]?.cancel();
      _debounceTimers.remove(key);

      try {
        await _storage.delete(key);
      } catch (e) {
        logger.warning('Failed to delete weight for key: $key, error: $e');
      }
    }
    notifyListeners();
  }

  Future<void> clearAll() async {
    logger.info('Clearing all score weights from memory and storage');
    if (!_initialized) await init();
    _weights.clear();
    await _storage.clear();
    notifyListeners();
  }
}
