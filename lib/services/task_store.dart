import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import 'task_storage_lock.dart';

typedef TaskMutation<T> = T Function(List<Task> tasks);

class TaskStore {
  static const key = 'arvin.tasks';

  // SharedPreferencesAsync has no legacy in-memory cache and therefore keeps
  // Android engine instances on the same platform-backed source of truth.
  // The legacy API remains a test fallback because the current Flutter test
  // binding does not register SharedPreferencesAsyncPlatform automatically.
  SharedPreferencesAsync? _preferences;

  Future<List<Task>> load() =>
      TaskStorageLock.synchronized<List<Task>>(_loadUnlocked);

  Future<void> save(List<Task> tasks) =>
      TaskStorageLock.synchronized<void>(() => _saveUnlocked(tasks));

  /// Executes one canonical read-modify-write operation under the shared
  /// storage lock. Feature repositories should prefer this over separate
  /// load()/save() calls when they mutate the task collection.
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

  Future<String?> _readRaw() async {
    try {
      _preferences ??= SharedPreferencesAsync();
      return await _preferences!.getString(key);
    } on StateError catch (error) {
      if (!error.message.contains('SharedPreferencesAsyncPlatform instance')) {
        rethrow;
      }
      final legacy = await SharedPreferences.getInstance();
      return legacy.getString(key);
    }
  }

  Future<void> _writeRaw(String encoded) async {
    try {
      _preferences ??= SharedPreferencesAsync();
      final saved = await _preferences!.setString(key, encoded);
      if (!saved) {
        throw StateError('Canonical task storage write could not be verified');
      }

      final verified = await _preferences!.getString(key);
      if (verified != encoded) {
        throw StateError('Canonical task storage write could not be verified');
      }
    } on StateError catch (error) {
      if (!error.message.contains('SharedPreferencesAsyncPlatform instance')) {
        rethrow;
      }
      final legacy = await SharedPreferences.getInstance();
      final saved = await legacy.setString(key, encoded);
      if (!saved) {
        throw StateError('Canonical task storage write could not be verified');
      }
      await legacy.reload();
      if (legacy.getString(key) != encoded) {
        throw StateError('Canonical task storage write could not be verified');
      }
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
