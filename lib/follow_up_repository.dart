import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/task.dart';

/// Persistence boundary for FollowUp data.
///
/// It deliberately preserves the existing `arvin.tasks` JSON envelope so the
/// current application data remains backward compatible while the UI is
/// migrated from the legacy `followUpDate` field to `followUps`.
class FollowUpRepository {
  const FollowUpRepository({this.key = 'arvin.tasks'});

  final String key;

  Future<List<FollowUp>> loadForTask(String taskId) async {
    final tasks = await _loadRawTasks();
    final raw = tasks.cast<Map<String, dynamic>>().firstWhere(
          (task) => task['id'] == taskId,
          orElse: () => <String, dynamic>{},
        );

    if (raw.isEmpty) return const [];

    final followUps = raw['followUps'];
    if (followUps is List) {
      return followUps
          .whereType<Map>()
          .map((item) => FollowUp.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    final legacy = raw['followUpDate'];
    if (legacy is String) {
      final date = DateTime.tryParse(legacy);
      if (date != null) {
        return [
          FollowUp(
            id: date.microsecondsSinceEpoch.toString(),
            dateTime: date,
            note: 'مهاجرت خودکار از تاریخ پیگیری قبلی',
          ),
        ];
      }
    }

    return const [];
  }

  Future<void> add(String taskId, FollowUp followUp) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await _loadRawTasks(prefs: prefs);
    final index = tasks.indexWhere((task) => task['id'] == taskId);
    if (index < 0) {
      throw StateError('Task not found: $taskId');
    }

    final task = tasks[index];
    final existing = await loadForTask(taskId);
    final merged = [...existing, followUp];
    task['followUps'] = merged.map((item) => item.toJson()).toList();

    await prefs.setString(key, jsonEncode(tasks));
  }

  Future<List<Map<String, dynamic>>> _loadRawTasks({
    SharedPreferences? prefs,
  }) async {
    final store = prefs ?? await SharedPreferences.getInstance();
    final raw = store.getString(key);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
