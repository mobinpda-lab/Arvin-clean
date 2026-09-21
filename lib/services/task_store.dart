import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import 'task_storage_lock.dart';

typedef TaskMutation<T> = T Function(List<Task> tasks);

class TaskStore {
  static const key = 'arvin.tasks';

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
      if (index < 0) throw StateError('Task not found: $taskId');
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

  Future<String?> _readRaw() async {
    try {
      // SharedPreferencesAsync has no local cache and therefore always reads
      // the latest native value. This is important on Android where another
      // Flutter/plugin context may have written the same canonical key.
      final preferences = SharedPreferencesAsync();
      return await preferences.getString(key);
    } on StateError {
      // Flutter unit tests do not register the async platform by default.
      // Keep the test fallback isolated and refresh its legacy cache before
      // every read so setMockInitialValues() is respected between tests.
      final preferences = await SharedPreferences.getInstance();
      await preferences.reload();
      return preferences.getString(key);
    }
  }

  Future<void> _writeRaw(String encoded) async {
    try {
      final preferences = SharedPreferencesAsync();
      await preferences.setString(key, encoded);
      final acknowledged = await preferences.getString(key);
      if (acknowledged != encoded) {
        throw StateError('Canonical task storage write could not be verified');
      }
      return;
    } on StateError catch (error) {
      // Only platform-registration failures should reach this fallback.
      // Storage verification failures must remain real failures.
      if (!error.toString().contains('SharedPreferencesAsyncPlatform')) {
        rethrow;
      }
    }

    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(key, encoded);
    if (!saved) {
      throw StateError('Canonical task storage write could not be verified');
    }
    await preferences.reload();
    if (preferences.getString(key) != encoded) {
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
