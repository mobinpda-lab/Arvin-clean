import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/task.dart';

/// Persistence boundary for FollowUp data.
///
/// It preserves the existing `arvin.tasks` JSON envelope so current data
/// remains backward compatible while the UI migrates from `followUpDate` to
/// `followUps`.
class FollowUpRepository {
  const FollowUpRepository({this.key = 'arvin.tasks'});

  final String key;

  Future<List<FollowUp>> loadForTask(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    return _loadForTask(prefs, taskId);
  }

  Future<void> add(String taskId, FollowUp followUp) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await _loadRawTasks(prefs);
    final index = tasks.indexWhere((task) => task['id'] == taskId);
    if (index < 0) {
      throw StateError('Task not found: $taskId');
    }

    final existing = _decodeFollowUps(tasks[index]);
    final task = tasks[index];
    task['followUps'] = [...existing, followUp]
        .map((item) => item.toJson())
        .toList();

    await prefs.setString(key, jsonEncode(tasks));
  }

  Future<List<FollowUp>> _loadForTask(
    SharedPreferences prefs,
    String taskId,
  ) async {
    final tasks = await _loadRawTasks(prefs);
    final raw = tasks.where((task) => task['id'] == taskId).firstOrNull;
    if (raw == null) return const [];
    return _decodeFollowUps(raw);
  }

  List<FollowUp> _decodeFollowUps(Map<String, dynamic> raw) {
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

  Future<List<Map<String, dynamic>>> _loadRawTasks(
    SharedPreferences prefs,
  ) async {
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
