import 'task_store.dart';

/// Source-compatible facade over the canonical SQLite Tag catalog.
///
/// SharedPreferences remains a read-only migration source inside TaskStore;
/// this adapter never writes a second Tag catalog.
class TagStore {
  TagStore({TaskStore? store}) : _store = store ?? TaskStore();

  final TaskStore _store;

  Future<List<String>> load() => _store.loadTags();

  Future<List<String>> add(String value) async {
    await _store.createTag(value);
    return _store.loadTags();
  }

  /// Removal is dependency-safe: TaskStore rejects deletion while any Task or
  /// template still references the Tag.
  Future<List<String>> remove(String value) async {
    await _store.deleteTagCatalog(value);
    return _store.loadTags();
  }
}
