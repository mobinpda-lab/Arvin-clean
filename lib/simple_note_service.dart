import 'models/simple_note.dart';
import 'simple_note_repository.dart';

/// Application-level CRUD rules for the simple notebook.
///
/// UI/session concerns stay outside this service. In particular, the
/// read-only-after-exit policy is enforced by the UI; persistence is always
/// explicit through this service so autosave can be tested independently.
class SimpleNoteService {
  SimpleNoteService(this._repository);

  final SimpleNoteRepository _repository;

  Future<List<SimpleNote>> list() => _repository.load();

  Future<SimpleNote> create({
    String title = '',
    String body = '',
    DateTime? dateTime,
  }) async {
    final notes = await _repository.load();
    final note = SimpleNote(
      id: _newId(notes),
      title: title,
      body: body,
      dateTime: dateTime ?? DateTime.now(),
    );
    notes.add(note);
    await _repository.save(notes);
    return note;
  }

  Future<void> update(SimpleNote note) async {
    final notes = await _repository.load();
    final index = notes.indexWhere((item) => item.id == note.id);
    if (index < 0) {
      throw StateError('SimpleNote not found: ${note.id}');
    }
    notes[index] = note;
    await _repository.save(notes);
  }

  Future<void> delete(String id) async {
    final notes = await _repository.load();
    notes.removeWhere((note) => note.id == id);
    await _repository.save(notes);
  }

  String _newId(List<SimpleNote> notes) {
    final stamp = DateTime.now().microsecondsSinceEpoch.toString();
    var id = 'note-$stamp';
    var suffix = 0;
    while (notes.any((note) => note.id == id)) {
      suffix++;
      id = 'note-$stamp-$suffix';
    }
    return id;
  }
}
