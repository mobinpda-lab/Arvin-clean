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

  Future<List<Task>> _loadUnlocked() async {
    // Refresh the legacy SharedPreferences cache before every canonical read.
    // Quick Capture can be exercised through a separate Flutter engine during
    // Android integration tests, so a stale per-engine cache must not hide a
    // task written by another engine.
    final preferences = _asyncPreferencesOrNull();
    final raw = preferences != null
        ? await preferences.getString(key)
        : (await SharedPreferences.getInstance()).getString(key);
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
    final preferences = _asyncPreferencesOrNull();
    final encoded = jsonEncode(tasks.map((task) => task.toJson()).toList());

    // Validate the exact document before replacing the canonical value.
    final decoded = jsonDecode(encoded);
    if (decoded is! List) {
      throw const FormatException('Refusing to persist invalid task document');
    }

    // The async API writes directly through the platform-backed store instead
    // of updating a per-engine Dart cache. Verify by reading through the same
    // uncached API; this keeps sequential Quick Capture writes on one
    // canonical arvin.tasks path.
    if (preferences != null) {
      await preferences.setString(key, encoded);
      final verified = await preferences.getString(key);
      if (verified != encoded) {
        throw StateError('Canonical task storage write could not be verified');
      }
      return;
    }

    final legacy = await SharedPreferences.getInstance();
    await legacy.setString(key, encoded);
    await legacy.reload();
    final verified = legacy.getString(key);
    if (verified != encoded) {
      throw StateError('Canonical task storage write could not be verified');
    }
  }

  SharedPreferencesAsync? _asyncPreferencesOrNull() {
    try {
      return SharedPreferencesAsync();
    } on StateError catch (error) {
      if (error.message.contains('SharedPreferencesAsyncPlatform instance must be set')) {
        return null;
      }
      rethrow;
    }
  }
}
