import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/simple_note.dart';

class SimpleNoteRepository {
  SimpleNoteRepository({SharedPreferences? prefs}) : _prefs = prefs;

  static const String key = 'arvin.simple_notes';
  final SharedPreferences? _prefs;

  Future<List<SimpleNote>> load() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => SimpleNote.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<SimpleNote> notes) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(key, encodeSimpleNotes(notes));
  }
}
