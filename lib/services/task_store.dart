import 'dart:convert';
import 'dart:io' show Platform;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';

import '../models/task.dart';
import 'task_storage_lock.dart';

typedef TaskMutation<T> = T Function(List<Task> tasks);

class TaskStore {
  static const key = 'arvin.tasks';
  static List<Task>? _androidSnapshot;

  /// Clears the process-local Android snapshot at a real app bootstrap.
  /// Native storage remains the source of truth; this only prevents a stale
  /// snapshot from surviving a new app tree in the same test process.
  static void resetProcessSnapshot() {
    _androidSnapshot = null;
  }

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
      final preferences = _asyncPreferences();
      return await preferences.getString(key);
    } on StateError catch (error) {
      if (!error.toString().contains('SharedPreferencesAsyncPlatform')) rethrow;
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
      final preferences = _asyncPreferences();
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

  SharedPreferencesAsync _asyncPreferences() {
    const options = SharedPreferencesAsyncAndroidOptions(
      backend: SharedPreferencesAndroidBackendLibrary.SharedPreferences,
    );
    return SharedPreferencesAsync(options: options);
  }

  Future<List<Task>> _loadUnlocked() async {
    if (Platform.isAndroid && _androidSnapshot != null) {
      return List<Task>.of(_androidSnapshot!);
    }
    final raw = await _readRaw();
    if (raw == null || raw.trim().isEmpty) return <Task>[];
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Canonical task storage must contain a list');
    }
    final loaded = decoded.map((item) {
      if (item is! Map) {
        throw const FormatException('Canonical task entry must be an object');
      }
      return Task.fromJson(Map<String, dynamic>.from(item));
    }).toList();
    if (Platform.isAndroid) {
      _androidSnapshot = List<Task>.of(loaded);
    }
    return loaded;
  }

  Future<void> _saveUnlocked(List<Task> tasks) async {
    final encoded = jsonEncode(tasks.map((task) => task.toJson()).toList());
    final decoded = jsonDecode(encoded);
    if (decoded is! List) {
      throw const FormatException('Refusing to persist invalid task document');
    }
    await _writeRaw(encoded);
    if (Platform.isAndroid) {
      _androidSnapshot = List<Task>.of(tasks);
      // Re-read the native value after the write acknowledgement. This closes
      // the Android backend hand-off window before the next mutation starts.
      for (var attempt = 0; attempt < 5; attempt += 1) {
        final persisted = await _readRaw();
        if (persisted == encoded) return;
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      throw StateError('Canonical task storage write was not stable after verification');
    }
  }
}
