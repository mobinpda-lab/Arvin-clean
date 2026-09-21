import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import 'task_storage_lock.dart';

typedef TaskMutation<T> = T Function(List<Task> tasks);

class TaskStore {
  static const key = 'arvin.tasks';

  // Android production uses the uncached async API so another app/test
  // instance cannot observe a stale per-instance cache. Pure Flutter tests
  // do not register the async platform implementation, so they fall back to
  // the legacy mockable API without changing the Android production path.
  SharedPreferencesAsync? _asyncPreferences;

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

  SharedPreferencesAsync? _createAsyncPreferences() {
    try {
      return SharedPreferencesAsync();
    } on StateError {
      return null;
    }
  }

  Future<String?> _readRaw() async {
    final asyncPreferences =
        _asyncPreferences ??= _createAsyncPreferences();
    if (asyncPreferences != null) {
      return asyncPreferences.getString(key);
    }

    final legacyPreferences = await SharedPreferences.getInstance();
    await legacyPreferences.reload();
    return legacyPreferences.getString(key);
  }

  Future<void> _writeRaw(String encoded) async {
    final asyncPreferences =
        _asyncPreferences ??= _createAsyncPreferences();
    if (asyncPreferences != null) {
      await asyncPreferences.setString(key, encoded);

      final acknowledged = await asyncPreferences.getString(key);
      if (acknowledged != encoded) {
        throw StateError('Canonical task storage write could not be verified');
      }
      return;
    }

    final legacyPreferences = await SharedPreferences.getInstance();
    final saved = await legacyPreferences.setString(key, encoded);
    if (!saved) {
      throw StateError('Canonical task storage write could not be verified');
    }
    await legacyPreferences.reload();
    if (legacyPreferences.getString(key) != encoded) {
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
