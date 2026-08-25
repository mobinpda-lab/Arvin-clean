import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_migration_reader.dart';
import 'package:arvin/services/task_migration_writer.dart';

void main() {
  const key = TaskMigrationReader.legacyKey;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('Home updates preserve canonical and future fields on the same key',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      key: '''[
        {
          "id": "canonical-1",
          "title": "عنوان قدیمی",
          "description": "شرح قدیمی",
          "createdAt": "2026-08-20T08:00:00.000Z",
          "updatedAt": "2026-08-21T09:00:00.000Z",
          "followUpEnabled": true,
          "followUpDate": "2026-08-26T10:00:00.000Z",
          "tags": ["قدیمی"],
          "category": "sales",
          "checklist": ["تماس"],
          "reminderDate": "2026-08-26T09:30:00.000Z",
          "archived": false,
          "trashed": false,
          "completed": false,
          "followUps": [
            {
              "id": "follow-up-1",
              "dateTime": "2026-08-25T10:00:00.000Z",
              "note": "پیگیری اولیه",
              "result": null,
              "nextFollowUp": null
            }
          ],
          "recurrence": {"frequency": "weekly", "interval": 2},
          "futureField": {"keep": true}
        }
      ]''',
    });
    final prefs = await SharedPreferences.getInstance();

    await TaskMigrationWriter().saveTo(
      prefs,
      <Task>[
        Task(
          id: 'canonical-1',
          title: 'عنوان ویرایش‌شده',
          description: 'شرح ویرایش‌شده',
          followUpDate: DateTime.parse('2026-08-27T11:00:00.000Z'),
          tags: const <String>['جدید'],
          archived: true,
          completed: true,
        ),
      ],
    );

    final saved = Map<String, dynamic>.from(
      (jsonDecode(prefs.getString(key)!) as List<dynamic>).single as Map,
    );
    expect(saved['title'], 'عنوان ویرایش‌شده');
    expect(saved['description'], 'شرح ویرایش‌شده');
    expect(saved['followUpDate'], '2026-08-27T11:00:00.000Z');
    expect(saved['tags'], <String>['جدید']);
    expect(saved['archived'], isTrue);
    expect(saved['completed'], isTrue);

    expect(saved['createdAt'], '2026-08-20T08:00:00.000Z');
    expect(saved['updatedAt'], '2026-08-21T09:00:00.000Z');
    expect(saved['followUpEnabled'], isTrue);
    expect(saved['category'], 'sales');
    expect(saved['checklist'], <String>['تماس']);
    expect(saved['reminderDate'], '2026-08-26T09:30:00.000Z');
    expect(
      saved['recurrence'],
      <String, dynamic>{'frequency': 'weekly', 'interval': 2},
    );
    expect(saved['futureField'], <String, dynamic>{'keep': true});
    expect(prefs.getKeys(), <String>{key});

    final canonical = TaskMigrationReader().loadFrom(prefs).single;
    expect(canonical.followUps.single.id, 'follow-up-1');
    expect(canonical.recurrence?.frequency.name, 'weekly');
    expect(canonical.recurrence?.interval, 2);
  });

  test('Home snapshot deletes omitted items and serializes new items canonically',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      key: '''[
        {"id":"remove","title":"حذف"},
        {"id":"keep","title":"نگه‌داری","category":"work"}
      ]''',
    });
    final prefs = await SharedPreferences.getInstance();

    await TaskMigrationWriter().saveTo(
      prefs,
      <Task>[
        Task(id: 'keep', title: 'ویرایش', completed: true),
        Task(id: 'new', title: 'تازه', followUpEnabled: true),
      ],
    );

    final saved =
        (jsonDecode(prefs.getString(key)!) as List<dynamic>)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
    expect(saved.map((item) => item['id']), <String>['keep', 'new']);
    expect(saved.first['category'], 'work');
    expect(saved.first['completed'], isTrue);
    expect(saved.last['followUpEnabled'], isTrue);
    expect(saved.last['followUps'], isEmpty);
  });

  test('malformed existing storage is rejected without overwriting it',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{key: 'not-json'});
    final prefs = await SharedPreferences.getInstance();

    await expectLater(
      TaskMigrationWriter().saveTo(
        prefs,
        <Task>[Task(id: 'safe', title: 'نباید نوشته شود')],
      ),
      throwsA(isA<FormatException>()),
    );

    expect(prefs.getString(key), 'not-json');
  });

  test('duplicate Home ids are rejected without overwriting storage', () async {
    const original = '[{"id":"original","title":"موجود"}]';
    SharedPreferences.setMockInitialValues(<String, Object>{key: original});
    final prefs = await SharedPreferences.getInstance();

    await expectLater(
      TaskMigrationWriter().saveTo(
        prefs,
        <Task>[
          Task(id: 'duplicate', title: 'یک'),
          Task(id: 'duplicate', title: 'دو'),
        ],
      ),
      throwsA(isA<FormatException>()),
    );

    expect(prefs.getString(key), original);
  });
}
