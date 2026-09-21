import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import 'task_storage_lock.dart';

typedef TaskMutation<T> = T Function(List<Task> tasks);

class TaskStore {
  static const key = 'arvin.tasks';

  // One process-wide backend plus TaskStorageLock gives every TaskStore
  // instance the same in-memory view. We deliberately do not call reload()
  // between sequential writes: reloading a legacy SharedPreferences cache can
  // observe an older disk snapshot while the previous awaited write is still
  // being finalized on Android.
  static SharedPreferences? _preferences;

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

  Future<SharedPreferences> _backend() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<String?> _readRaw() async {
    final preferences = await _backend();
    return preferences.getString(key);
  }

  Future<void> _writeRaw(String encoded) async {
    final preferences = await _backend();
    final saved = await preferences.setString(key, encoded);
    if (!saved) {
      throw StateError('Canonical task storage write could not be verified');
    }

    // setString() is awaited and updates this process-wide singleton. Verify
    // the same canonical backend without reloading an older disk snapshot.
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
