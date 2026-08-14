import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskStore {
  static const key = 'arvin.tasks';

  Future<List<ArvinTask>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map>()
        .map((item) => ArvinTask.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }

  Future<void> save(List<ArvinTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      key,
      jsonEncode(tasks.map((task) => task.toJson()).toList()),
    );
  }
}
