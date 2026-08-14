import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/simple_note.dart';
import 'package:arvin/simple_note_repository.dart';
import 'package:arvin/simple_note_service.dart';

class _MemoryPrefs {
  final Map<String, String> values = <String, String>{};
}

void main() {
  test('create uses the system time when no timestamp is supplied', () async {
    final repository = SimpleNoteRepository();
    final service = SimpleNoteService(repository);
    final before = DateTime.now();
    final note = await service.create(title: 'موضوع', body: 'متن');
    final after = DateTime.now();

    expect(note.title, 'موضوع');
    expect(note.body, 'متن');
    expect(!note.dateTime.isBefore(before), isTrue);
    expect(!note.dateTime.isAfter(after), isTrue);
  });

  test('update keeps the note id and persists edited date/time', () async {
    final repository = SimpleNoteRepository();
    final service = SimpleNoteService(repository);
    final note = SimpleNote(
      id: 'n1',
      title: 'قدیم',
      body: 'متن',
      dateTime: DateTime(2026, 8, 14, 9, 0),
    );
    await repository.save(<SimpleNote>[note]);

    note.title = 'جدید';
    note.dateTime = DateTime(2026, 8, 12, 14, 30);
    await service.update(note);

    final restored = await service.list();
    expect(restored.single.id, 'n1');
    expect(restored.single.title, 'جدید');
    expect(restored.single.dateTime, DateTime(2026, 8, 12, 14, 30));
  });

  test('update rejects a note that does not exist', () async {
    final service = SimpleNoteService(SimpleNoteRepository());
    expect(
      () => service.update(
        SimpleNote(
          id: 'missing',
          title: '',
          body: '',
          dateTime: DateTime(2026, 8, 14),
        ),
      ),
      throwsStateError,
    );
  });
}
