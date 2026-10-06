import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/models/phase2/landing_task.dart';
import '../../../domain/repositories/phase2/landing_repository.dart';

class LandingRepositoryImpl implements LandingRepository {
  static const String _completedKey = 'phase2_completed_tasks';

  @override
  Future<List<LandingTask>> getTasks() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/checklist_phase2.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);
      final List<dynamic> list = data['tasks'] ?? [];

      final prefs = await SharedPreferences.getInstance();
      final completedIds = prefs.getStringList(_completedKey) ?? [];

      return list.map((item) {
        final id = item['id'] as String? ?? '';
        final isDone = completedIds.contains(id);
        return LandingTask.fromJson(item as Map<String, dynamic>, isCompleted: isDone);
      }).toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> toggleTaskCompleted(String taskId, bool isCompleted) async {
    final prefs = await SharedPreferences.getInstance();
    final completedIds = (prefs.getStringList(_completedKey) ?? []).toSet();

    if (isCompleted) {
      completedIds.add(taskId);
    } else {
      completedIds.remove(taskId);
    }

    await prefs.setStringList(_completedKey, completedIds.toList());
  }
}
