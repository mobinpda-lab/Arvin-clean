import 'models/simple_note.dart';

/// Pure editing policy for the simple notebook.
///
/// A new note receives the system date/time automatically. The user may edit
/// that value while the note is in edit mode. Leaving the page makes the note
/// read-only; a later explicit edit action re-enables editing.
class SimpleNoteSession {
  SimpleNoteSession({required this.note, this.isEditing = true});

  factory SimpleNoteSession.createNew({DateTime? now}) {
    final timestamp = now ?? DateTime.now();
    return SimpleNoteSession(
      note: SimpleNote(
        id: timestamp.microsecondsSinceEpoch.toString(),
        title: '',
        body: '',
        dateTime: timestamp,
      ),
    );
  }

  final SimpleNote note;
  bool isEditing;

  bool get isReadOnly => !isEditing;

  void updateDateTime(DateTime value) {
    if (!isEditing) return;
    note.dateTime = value;
  }

  void updateTitle(String value) {
    if (!isEditing) return;
    note.title = value;
  }

  void updateBody(String value) {
    if (!isEditing) return;
    note.body = value;
  }

  void exit() => isEditing = false;

  void edit() => isEditing = true;
}
