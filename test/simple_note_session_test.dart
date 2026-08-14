import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/simple_note_session.dart';

void main() {
  test('new note gets the supplied system date and time automatically', () {
    final now = DateTime(2026, 8, 14, 19, 30);
    final session = SimpleNoteSession.createNew(now: now);

    expect(session.note.dateTime, now);
    expect(session.isEditing, isTrue);
  });

  test('date and time can be edited while the note is editable', () {
    final session = SimpleNoteSession.createNew(
      now: DateTime(2026, 8, 14, 19, 30),
    );
    final edited = DateTime(2026, 8, 13, 9, 15);

    session.updateDateTime(edited);

    expect(session.note.dateTime, edited);
  });

  test('leaving the note makes it read-only until explicit edit', () {
    final session = SimpleNoteSession.createNew(
      now: DateTime(2026, 8, 14, 19, 30),
    );
    final original = session.note.dateTime;
    final attempted = DateTime(2026, 8, 10, 8, 0);

    session.exit();
    session.updateDateTime(attempted);

    expect(session.isReadOnly, isTrue);
    expect(session.note.dateTime, original);

    session.edit();
    session.updateDateTime(attempted);

    expect(session.isEditing, isTrue);
    expect(session.note.dateTime, attempted);
  });
}
