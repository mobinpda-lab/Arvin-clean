import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/services/task_migration_adapter.dart';

void main() {
  const adapter = TaskMigrationAdapter();

  test('decodes legacy Home JSON into Unified Task without losing fields', () {
    const raw = '''[
      {
        "id": "legacy-1",
        "title": "تماس با مشتری",
        "description": "پیگیری قرارداد",
        "followUpDate": "2026-08-20T10:30:00.000Z",
        "tags": ["crm"],
        "category": "sales",
        "archived": false,
        "trashed": false,
        "completed": false
      }
    ]''';

    final tasks = adapter.decodeLegacyList(raw);

    expect(tasks, hasLength(1));
    final task = tasks.single;
    expect(task.id, 'legacy-1');
    expect(task.title, 'تماس با مشتری');
    expect(task.description, 'پیگیری قرارداد');
    expect(task.tags, ['crm']);
    expect(task.category, 'sales');
    expect(task.followUpDate, DateTime.parse('2026-08-20T10:30:00.000Z'));
    expect(task.followUps, hasLength(1));
    expect(task.followUps.single.dateTime,
        DateTime.parse('2026-08-20T10:30:00.000Z'));
    expect(task.archived, isFalse);
    expect(task.trashed, isFalse);
    expect(task.completed, isFalse);
  });

  test('decodes an empty legacy list', () {
    expect(adapter.decodeLegacyList('[]'), isEmpty);
  });

  test('decodes multiple legacy tasks', () {
    const raw = '''[
      {"id":"legacy-1","title":"one"},
      {"id":"legacy-2","title":"two"}
    ]''';

    final tasks = adapter.decodeLegacyList(raw);

    expect(tasks.map((task) => task.id), ['legacy-1', 'legacy-2']);
  });

  test('rejects a malformed non-object task item', () {
    expect(
      () => adapter.decodeLegacyList('[{"id":"ok"}, null]'),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects a legacy task without an id', () {
    expect(
      () => adapter.decodeLegacyList('[{"title":"missing id"}]'),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects duplicate task ids during migration', () {
    const raw = '''[
      {"id":"duplicate","title":"one"},
      {"id":"duplicate","title":"two"}
    ]''';

    expect(
      () => adapter.decodeLegacyList(raw),
      throwsA(isA<FormatException>()),
    );
  });

  test('Unified serialization remains readable by the migration boundary', () {
    const raw = '''[
      {
        "id": "legacy-2",
        "title": "یادداشت",
        "description": "متن",
        "tags": [],
        "archived": true,
        "trashed": false,
        "completed": true
      }
    ]''';

    final tasks = adapter.decodeLegacyList(raw);
    final encoded = adapter.encodeUnifiedList(tasks);
    final roundTrip = adapter.decodeLegacyList(encoded);

    expect(roundTrip.single.id, 'legacy-2');
    expect(roundTrip.single.title, 'یادداشت');
    expect(roundTrip.single.description, 'متن');
    expect(roundTrip.single.archived, isTrue);
    expect(roundTrip.single.completed, isTrue);
  });

  test('rejects duplicate ids when encoding Unified tasks', () {
    const raw = '[{"id":"same"}]';
    final task = adapter.decodeLegacyList(raw).single;

    expect(
      () => adapter.encodeUnifiedList([task, task]),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects a non-list storage payload', () {
    expect(
      () => adapter.decodeLegacyList('{"id":"not-a-list"}'),
      throwsA(isA<FormatException>()),
    );
  });
}
