import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/models/person_reference.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  late NativeDatabase database;

  setUp(() {
    database = NativeDatabase.memory();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await database.close();
  });

  test('cutover migrates legacy data and then reads only from SQL', () async {
    final legacy = <String, dynamic>{
      'id': 'sql-cutover-1',
      'title': 'تماس با مشتری',
      'description': 'شرح اولیه',
      'tags': ['مهم'],
      'category': 'فروش',
      'followUpEnabled': true,
      'followUps': [
        {
          'id': 'fu-1',
          'dateTime': '2026-09-20T10:00:00.000Z',
          'note': 'تماس شد',
          'completed': true,
        },
      ],
      'checklist': ['ارسال قرارداد'],
      'people': [
        PersonReference(id: 'person-1', displayName: 'مشتری').toJson(),
      ],
      'futureField': {'keep': true},
      'completed': false,
    };
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(TaskStore.key, jsonEncode([legacy]));

    final store = TaskStore(executor: database);
    final migrated = await store.load();

    expect(migrated, hasLength(1));
    expect(migrated.single.id, 'sql-cutover-1');
    expect(migrated.single.followUps.single.completed, isTrue);
    expect(migrated.single.people.single.id, 'person-1');

    await preferences.setString(
      TaskStore.key,
      jsonEncode([
        {
          'id': 'legacy-only',
          'title': 'نباید دوباره خوانده شود',
        },
      ]),
    );

    final freshReader = TaskStore(executor: database);
    final fromSql = await freshReader.load();

    expect(fromSql, hasLength(1));
    expect(fromSql.single.id, 'sql-cutover-1');
    expect(fromSql.single.title, 'تماس با مشتری');
  });

  test('SQL save preserves unknown legacy payload fields for an existing task', () async {
    final preferences = await SharedPreferences.getInstance();
    const legacy = '[{"id":"preserve-save-1","title":"قدیمی","futureField":{"keep":true,"version":7}}]';
    await preferences.setString(TaskStore.key, legacy);

    final store = TaskStore(executor: database);
    final loaded = await store.load();
    expect(loaded.single.id, 'preserve-save-1');

    loaded.single.title = 'به‌روزشده';
    await store.save(loaded);

    final rows = await database.runSelect(
      'SELECT legacy_payload_json FROM tasks WHERE id = ?',
      const ['preserve-save-1'],
    );
    final envelope =
        jsonDecode(rows.single['legacy_payload_json'] as String) as Map<String, dynamic>;
    expect(envelope['title'], 'به‌روزشده');
    expect(envelope['futureField'], {'keep': true, 'version': 7});
  });

  test('SQL save preserves identity, order, relations and survives a fresh store', () async {
    final first = Task(
      id: 'task-1',
      title: 'اول',
      tags: ['مهم', 'مشتری'],
      checklist: ['یک', 'دو'],
      people: [PersonReference(id: 'p-1', displayName: 'اول')],
    );
    final second = Task(
      id: 'task-2',
      title: 'دوم',
      completed: true,
      followUps: [
        FollowUp(
          id: 'fu-2',
          dateTime: DateTime.utc(2026, 9, 21, 10),
          note: 'پیگیری دوم',
        ),
      ],
    );

    final store = TaskStore(executor: database);
    await store.save([first, second]);

    final loaded = await TaskStore(executor: database).load();

    expect(loaded.map((task) => task.id), ['task-1', 'task-2']);
    expect(loaded.first.tags, ['مهم', 'مشتری']);
    expect(loaded.first.checklist, ['یک', 'دو']);
    expect(loaded.first.people.single.id, 'p-1');
    expect(loaded.last.completed, isTrue);
    expect(loaded.last.followUps.single.id, 'fu-2');
  });
}
