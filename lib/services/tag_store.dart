import 'package:shared_preferences/shared_preferences.dart';

class TagStore {
  static const key = 'arvin.tags';
  Future<List<String>> load() async => (await SharedPreferences.getInstance()).getStringList(key) ?? [];
  Future<List<String>> add(String value) async {
    final p = await SharedPreferences.getInstance();
    final tags = await load();
    final v = value.trim();
    if (v.isNotEmpty && !tags.contains(v)) tags.add(v);
    await p.setStringList(key, tags);
    return tags;
  }
  Future<List<String>> remove(String value) async {
    final p = await SharedPreferences.getInstance();
    final tags = await load();
    tags.remove(value);
    await p.setStringList(key, tags);
    return tags;
  }
}
