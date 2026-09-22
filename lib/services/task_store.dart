import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';

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

  // The canonical task document remains on the existing arvin.tasks key.
  // Use SharedPreferencesAsync without a Dart-side cache, while explicitly
  // selecting the native Android SharedPreferences backend. This keeps the
  // incremental migration compatible with the existing key and prevents
  // separate Flutter engines/isolate caches from observing stale snapshots.
  static const SharedPreferencesAsyncAndroidOptions _androidOptions =
      SharedPreferencesAsyncAndroidOptions(
    backend: SharedPreferencesAndroidBackendLibrary.SharedPreferences,
  );

  Future<String?> _readRaw() async {
    final preferences = SharedPreferencesAsync();
    return preferences.getString(
      key,
      options: _androidOptions,
    );
  }

  Future<void> _writeRaw(String encoded) async {
    final preferences = SharedPreferencesAsync();
    await preferences.setString(
      key,
      encoded,
      options: _androidOptions,
    );

    final persisted = await preferences.getString(
      key,
      options: _androidOptions,
    );
    if (persisted != encoded) {
      throw StateError(
        'Canonical task storage write could not be verified',
      );
    }
  }

  Future<List<Task>> _loadUnlocked() async {
    final raw = await _readRaw();
    if (raw == null || raw.trim().isEmpty) return <Task>[];

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException(
        'Canonical task storage must contain a list',
      );
    }

    return decoded.map((item) {
      if (item is! Map) {
        throw const FormatException(
          'Canonical task entry must be an object',
        );
      }
      return Task.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  Future<void> _saveUnlocked(List<Task> tasks) async {
    final encoded = jsonEncode(
      tasks.map((task) => task.toJson()).toList(),
    );
    final decoded = jsonDecode(encoded);
    if (decoded is! List) {
      throw const FormatException(
        'Refusing to persist invalid task document',
      );
    }

    await _writeRaw(encoded);
  }
}