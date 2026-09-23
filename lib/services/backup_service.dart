import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'task_store.dart';
import '../models/task.dart';

class BackupService {
  BackupService({TaskStore? taskStore}) : _taskStore = taskStore ?? TaskStore();

  final TaskStore _taskStore;
  Future<String> exportJson() async {
    final p = await SharedPreferences.getInstance();
    final data = <String, dynamic>{};
    final tasks = await _taskStore.load();
    for (final k in p.getKeys()) {
      final v = p.get(k);
      if (k == TaskStore.key) {
        data[k] = tasks.map((task) => task.toJson()).toList();
      } else if (v is String || v is bool || v is int || v is double || v is List<String>) {
        data[k] = v;
      }
    }
    return const JsonEncoder.withIndent('  ').convert({
      'format': 'arvin-backup',
      'version': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'data': data,
    });
  }

  Future<void> importJson(String text) async {
    final root = jsonDecode(text);
    if (root is! Map || root['format'] != 'arvin-backup' || root['data'] is! Map) {
      throw const FormatException('Invalid Arvin backup');
    }
    final p = await SharedPreferences.getInstance();
    final data = Map<String, dynamic>.from(root['data'] as Map);
    final taskPayload = data.remove(TaskStore.key);
    if (taskPayload is List) {
      await _taskStore.save(
        taskPayload
            .whereType<Map>()
            .map((item) => Task.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
      );
    }
    for (final e in data.entries) {
      final v = e.value;
      if (v is String) {
        await p.setString(e.key, v);
      } else if (v is bool) {
        await p.setBool(e.key, v);
      } else if (v is int) {
        await p.setInt(e.key, v);
      } else if (v is double) {
        await p.setDouble(e.key, v);
      } else if (v is List) {
        await p.setStringList(e.key, v.map((x) => x.toString()).toList());
      }
    }
  }
}
