import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BackupService {
  Future<String> exportJson() async {
    final p = await SharedPreferences.getInstance();
    final data = <String, dynamic>{};
    for (final k in p.getKeys()) {
      final v = p.get(k);
      if (v is String || v is bool || v is int || v is double || v is List<String>) {
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
    for (final e in (root['data'] as Map).entries) {
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
