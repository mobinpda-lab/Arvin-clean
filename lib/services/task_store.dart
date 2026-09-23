import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import 'task_storage_lock.dart';

typedef TaskMutation<T> = T Function(List<Task> tasks);

class TaskStore {
  static const key = 'arvin.tasks';

  SharedPreferences? _preferences;

  Future<List<Task>> load() =>
      TaskStorageLock.synchronized<List<Task>>(_loadUnlocked);

  Future<void> save(List<Task> tasks) =>
      TaskStorageLock.synchronized<void>(() => _saveUnlocked(tasks));

  Future<T> mutate<T>(TaskMutation<T> mutation) {
    return TaskStorageLock.synchronized<T>(() async {
      final tasks = await _loadUnlocked();
      final result = mutation(tasks);
      await _saveUnlocked(tasks);
      return result;
    });
  }

  Future<void> addFollowUp(String taskId, FollowUp followUp) async {
    await mutate<void>((tasks) {
      final index = tasks.indexWhere((task) => task.id == taskId);
      if (index < 0) {
        throw StateError('Task not found: $taskId');
      }

      final task = tasks[index];
      task.followUps = [...task.followUps, followUp];
      task.followUpEnabled = true;
      task.updatedAt = DateTime.now();
    });
  }

  Future<List<FollowUp>> loadFollowUps(String taskId) async {
    final tasks = await load();
    for (final task in tasks) {
      if (task.id == taskId) return List<FollowUp>.of(task.followUps);
    }
    return const [];
  }

  Future<SharedPreferences> _prefs() async {
    final preferences = _preferences ??= await SharedPreferences.getInstance();
    await preferences.reload();
    return preferences;
  }

  Future<String?> _readRaw() async {
    final preferences = await _prefs();
    return preferences.getString(key);
  }

  Future<void> _writeRaw(String encoded) async {
    final preferences = await _prefs();
    final saved = await preferences.setString(key, encoded);
    await preferences.reload();
    if (!saved || preferences.getString(key) != encoded) {
      throw StateError('Canonical task storage write could not be verified');
    }
  }

  Future<List<Task>> _loadUnlocked() async {
    final raw = await _readRaw();
    if (raw == null || raw.trim().isEmpty) return <Task>[];

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Canonical task storage must contain a list');
    }

    return decoded.map((item) {
      if (item is! Map) {
        throw const FormatException('Canonical task entry must be an object');
      }
      return Task.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  Future<void> _saveUnlocked(List<Task> tasks) async {
    final encoded = jsonEncode(tasks.map((task) => task.toJson()).toList());
    final decoded = jsonDecode(encoded);
    if (decoded is! List) {
      throw const FormatException('Refusing to persist invalid task document');
    }

    await _writeRaw(encoded);
  }
}
