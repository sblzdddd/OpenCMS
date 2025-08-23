import 'dart:convert';
import '../../data/models/homework/homework_response.dart';
import '../shared/storage_client.dart';

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
      print('Error reading completed homeworks: $e');
      return [];
    }
  }
  
  /// Check if a homework is completed by matching courseName and title
  static Future<bool> isHomeworkCompleted(HomeworkItem homework) async {
    final completed = await getCompletedHomeworks();
    return completed.any((completed) => 
      completed.courseName == homework.courseName && 
      completed.title == homework.title
    );
  }
  
  /// Mark a homework as completed
  static Future<void> markHomeworkCompleted(HomeworkItem homework) async {
    try {
      final completed = await getCompletedHomeworks();
      
      // Check if already exists
      final exists = completed.any((completed) => 
        completed.courseName == homework.courseName && 
        completed.title == homework.title
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
      print('Error marking homework as completed: $e');
    }
  }
  
  /// Mark a homework as not completed (remove from completed list)
  static Future<void> markHomeworkNotCompleted(HomeworkItem homework) async {
    try {
      final completed = await getCompletedHomeworks();
      completed.removeWhere((completed) => 
        completed.courseName == homework.courseName && 
        completed.title == homework.title
      );
      
      await _saveCompletedHomeworks(completed);
    } catch (e) {
      print('Error marking homework as not completed: $e');
    }
  }
  
  /// Clear all completed homeworks
  static Future<void> clearCompletedHomeworks() async {
    try {
      await StorageClient.instance.delete(key: _storageKey);
    } catch (e) {
      print('Error clearing completed homeworks: $e');
    }
  }
  
  /// Save completed homeworks to storage
  static Future<void> _saveCompletedHomeworks(List<CompletedHomework> homeworks) async {
    try {
      final jsonList = homeworks.map((hw) => hw.toJson()).toList();
      final data = jsonEncode(jsonList);
      await StorageClient.instance.write(key: _storageKey, value: data);
    } catch (e) {
      print('Error saving completed homeworks: $e');
    }
  }
}

/// Model for storing completed homework information
class CompletedHomework {
  final String courseName;
  final String title;
  final DateTime completedAt;
  final int homeworkId;
  
  CompletedHomework({
    required this.courseName,
    required this.title,
    required this.completedAt,
    required this.homeworkId,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'courseName': courseName,
      'title': title,
      'completedAt': completedAt.millisecondsSinceEpoch,
      'homeworkId': homeworkId,
    };
  }
  
  factory CompletedHomework.fromJson(Map<String, dynamic> json) {
    return CompletedHomework(
      courseName: json['courseName'] as String,
      title: json['title'] as String,
      completedAt: DateTime.fromMillisecondsSinceEpoch(json['completedAt'] as int),
      homeworkId: json['homeworkId'] as int,
    );
  }
}
