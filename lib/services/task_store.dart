import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskStore {
  static const key = 'arvin.tasks';

  Future<List<Task>> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .map((item) => Task.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> save(List<Task> tasks) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      key,
      jsonEncode(tasks.map((task) => task.toJson()).toList()),
    );
  }

  Future<void> addFollowUp(String taskId, FollowUp followUp) async {
    final tasks = await load();
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index < 0) {
      throw StateError('Task not found: $taskId');
    }

    final task = tasks[index];
    task.followUps = [...task.followUps, followUp];
    await save(tasks);
  }

  Future<List<FollowUp>> loadFollowUps(String taskId) async {
    final tasks = await load();
    for (final task in tasks) {
      if (task.id == taskId) return List<FollowUp>.of(task.followUps);
    }
    return const [];
  }
}
