import 'dart:convert';
import '../models/homework_models.dart';
import '../../API/storage/storage_client.dart';
import 'package:flutter/foundation.dart';

/// Service for managing completed homework items in local storage
class CompletedHomeworkService {
  static const String _storageKey = 'completed_homeworks';

  /// Get all completed homework items
  static Future<List<CompletedHomework>> getCompletedHomeworks() async {
    try {
      final data = await StorageClient.instance.read(key: _storageKey);
      if (data == null) return [];

      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => CompletedHomework.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error reading completed homeworks: $e');
      return [];
    }
  }

  /// Check if a homework is completed by matching courseName and title
  static Future<bool> isHomeworkCompleted(HomeworkItem homework) async {
    final completed = await getCompletedHomeworks();
    return completed.any(
      (completed) =>
          completed.courseName == homework.courseName &&
          completed.title == homework.title,
    );
  }

  /// Mark a homework as completed
  static Future<void> markHomeworkCompleted(HomeworkItem homework) async {
    try {
      final completed = await getCompletedHomeworks();

      // Check if already exists
      final exists = completed.any(
        (completed) =>
            completed.courseName == homework.courseName &&
            completed.title == homework.title,
      );

      if (!exists) {
        final newCompleted = CompletedHomework(
          courseName: homework.courseName,
          title: homework.title,
          completedAt: DateTime.now(),
          homeworkId: homework.id,
        );

        completed.add(newCompleted);
        await _saveCompletedHomeworks(completed);
      }
    } catch (e) {
      debugPrint('Error marking homework as completed: $e');
    }
  }

  /// Mark a homework as not completed (remove from completed list)
  static Future<void> markHomeworkNotCompleted(HomeworkItem homework) async {
    try {
      final completed = await getCompletedHomeworks();
      completed.removeWhere(
        (completed) =>
            completed.courseName == homework.courseName &&
            completed.title == homework.title,
      );

      await _saveCompletedHomeworks(completed);
    } catch (e) {
      debugPrint('Error marking homework as not completed: $e');
    }
  }

  /// Clear all completed homeworks
  static Future<void> clearCompletedHomeworks() async {
    try {
      await StorageClient.instance.delete(key: _storageKey);
    } catch (e) {
      debugPrint('Error clearing completed homeworks: $e');
    }
  }

  /// Save completed homeworks to storage
  static Future<void> _saveCompletedHomeworks(
    List<CompletedHomework> homeworks,
  ) async {
    try {
      final jsonList = homeworks.map((hw) => hw.toJson()).toList();
      final data = jsonEncode(jsonList);
      await StorageClient.instance.write(key: _storageKey, value: data);
    } catch (e) {
      debugPrint('Error saving completed homeworks: $e');
    }
  }
}

