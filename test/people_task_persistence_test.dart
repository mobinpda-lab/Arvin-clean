import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';

import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_service.dart';
import 'package:arvin/models/person_reference.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_migration_writer.dart';
import 'package:arvin/services/person_follow_up_report_projection.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _PeopleBackupService extends ArvinBackupService {
  Map<String, dynamic>? writtenPayload;
  Map<String, dynamic>? restoreDocument;

  @override
  String createBackupFileName(DateTime dateTime) => 'people-backup.json';

  @override
  Future<void> writeBackup({
    required String directoryUri,
    required Map<String, dynamic> payload,
    required String fileName,
    bool uploadToCloud = true,
    String? encryptionPassphrase,
  }) async {
    writtenPayload = payload;
  }

  @override
  Future<Map<String, dynamic>?> readBackup({String? passphrase}) async {
    return restoreDocument;
  }
}

PersonReference _person(String id, String name) =>
    PersonReference(id: id, displayName: name);

void main() {
  setUp(() async {
    await TaskStore.resetTestDatabase();
  });
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('Person reference JSON round-trip keeps Arvin identity and label', () {
    final restored = PersonReference.fromJson(
      _person(' person:42 ', ' سارا احمدی ').toJson(),
    );

    expect(restored.id, 'person:42');
    expect(restored.displayName, 'سارا احمدی');
  });

  test('Task JSON round-trip preserves optional Person references', () {
    final original = Task(
      id: 'task-people-1',
      title: 'پیگیری مشتری',
      people: [
        _person('person-1', 'سارا'),
        _person('person-2', 'علی'),
      ],
    );

    final encoded = original.toJson();
    final restored = Task.fromJson(encoded);

    expect(encoded['people'], isA<List<dynamic>>());
    expect(restored.people.map((person) => person.id), [
      'person-1',
      'person-2',
    ]);
    expect(restored.people.map((person) => person.displayName), [
      'سارا',
      'علی',
    ]);
    expect(
      () => restored.people.add(_person('person-3', 'رضا')),
      throwsUnsupportedError,
    );
  });

  test('legacy Task JSON without people remains readable and empty', () {
    final restored = Task.fromJson(<String, dynamic>{
      'id': 'legacy-no-people',
      'title': 'داده قدیمی',
    });

    expect(restored.people, isEmpty);
    expect(restored.toJson().containsKey('people'), isFalse);
  });

  test('malformed or duplicate persisted Person references are rejected', () {
    expect(
      () => Task.fromJson(<String, dynamic>{
        'id': 'bad-shape',
        'title': 'bad',
        'people': 'not-a-list',
      }),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => Task.fromJson(<String, dynamic>{
        'id': 'bad-person',
        'title': 'bad',
        'people': [
          <String, dynamic>{'id': 'person-1'},
        ],
      }),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => Task.fromJson(<String, dynamic>{
        'id': 'duplicate-person',
        'title': 'bad',
        'people': [
          <String, dynamic>{'id': 'person-1', 'displayName': 'اول'},
          <String, dynamic>{'id': 'person-1', 'displayName': 'دوم'},
        ],
      }),
      throwsA(isA<FormatException>()),
    );
  });

  test('TaskStore uses the existing key and round-trips people and independent reminders', () async {
    final store = TaskStore();
    await store.save(<Task>[
      Task(
        id: 'store-people',
        title: 'ذخیره شخص',
        people: [_person('person-store', 'مریم')],
        taskReminders: [
          TaskReminder(
            id: 'store-r1',
            title: 'ذخیره — یادآور ۱',
            date: DateTime(2026, 10, 20, 10),
            sequence: 1,
          ),
          TaskReminder(
            id: 'store-r2',
            title: 'ذخیره — یادآور ۲',
            date: DateTime(2026, 10, 21),
            isAllDay: true,
            sequence: 2,
          ),
        ],
        nextReminderSequence: 3,
      ),
    ]);

    expect(await TaskStore().load(), hasLength(1));

    final loaded = await store.load();
    expect(loaded.single.people.single.id, 'person-store');
    expect(loaded.single.people.single.displayName, 'مریم');
    expect(loaded.single.taskReminders.map((item) => item.id), [
      'store-r1',
      'store-r2',
    ]);
    expect(loaded.single.taskReminders.last.isAllDay, isTrue);
    expect(loaded.single.nextReminderSequence, 3);
  });


  test('Task and Person links survive database close and reopen with valid foreign keys', () async {
    final directory = await Directory.systemTemp.createTemp('arvin-task-people-reopen-');
    final file = File('${directory.path}/arvin.sqlite');
    var database = NativeDatabase(file);
    try {
      final store = TaskStore(executor: database);
      final person = _person('person-restart', 'همکار پایدار');
      await store.save([
        Task(
          id: 'task-restart',
          title: 'رابطه پایدار پس از بازگشایی',
          people: [person],
        ),
      ]);
      expect(
        (await store.loadPeopleDirectory()).map((value) => value.id),
        ['person-restart'],
      );

      await database.close();
      database = NativeDatabase(file);
      final reopenedStore = TaskStore(executor: database);
      final restoredTask = (await reopenedStore.load()).single;
      expect(restoredTask.id, 'task-restart');
      expect(restoredTask.people.single.id, 'person-restart');
      expect(restoredTask.people.single.displayName, 'همکار پایدار');
      expect(
        (await reopenedStore.loadPeopleDirectory()).map((value) => value.id),
        ['person-restart'],
      );
      expect(
        await database.runSelect('PRAGMA foreign_key_check', const []),
        isEmpty,
      );
      final relation = await database.runSelect(
        'SELECT task_id, person_id FROM task_persons WHERE task_id = ?',
        const ['task-restart'],
      );
      expect(relation, hasLength(1));
      expect(relation.single['person_id'], 'person-restart');
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });

  test('deleting a directory Person preserves historical Task and Follow-up references without resurrection', () async {
    final store = TaskStore();
    final person = _person('person-history-1', 'سارا احمدی');
    await store.mergePeopleDirectory([person]);
    await store.save([
      Task(
        id: 'task-person-history',
        title: 'پرونده تاریخی',
        people: [person],
        followUps: [
          FollowUp(
            id: 'follow-up-person-history',
            dateTime: DateTime(2026, 11, 1, 10),
            note: 'ارتباط تاریخی',
            waitingForResponse: true,
            personIds: [person.id],
          ),
        ],
      ),
    ]);

    expect((await store.loadPeopleDirectory()).map((value) => value.id), [person.id]);
    await store.savePeopleDirectory(const <PersonReference>[]);

    expect(await store.loadPeopleDirectory(), isEmpty);
    var loaded = (await store.load()).single;
    expect(loaded.people, hasLength(1));
    expect(loaded.people.single.id, person.id);
    expect(loaded.people.single.isDeleted, isTrue);
    expect(loaded.people.single.displayLabel, 'شخص حذف‌شده');
    expect(loaded.followUps.single.id, 'follow-up-person-history');
    expect(loaded.followUps.single.personIds, [person.id]);

    final reportRows = const PersonFollowUpReportProjection().project(
      [loaded],
      people: const <PersonReference>[],
    );
    expect(reportRows, hasLength(1));
    expect(reportRows.single.people.single.displayLabel, 'شخص حذف‌شده');
    expect(reportRows.single.people.single.isDeleted, isTrue);

    // A normal Task rewrite must not silently restore active membership.
    await store.save([loaded]);
    loaded = (await store.load()).single;
    expect(await store.loadPeopleDirectory(), isEmpty);
    expect(loaded.people.single.isDeleted, isTrue);
    expect(loaded.followUps.single.personIds, [person.id]);
  });

  test('Home migration write preserves existing people during edit', () {
    final existing = Task(
      id: 'home-edit-people',
      title: 'قبل',
      people: [_person('person-home', 'رضا')],
    );
    final homeProjection = Task(
      id: 'home-edit-people',
      title: 'بعد',
      description: 'ویرایش Home',
    );

    final encoded = TaskMigrationWriter().mergeHomeSnapshot(
      existingRaw: jsonEncode(<Map<String, dynamic>>[existing.toJson()]),
      homeSnapshot: <Task>[homeProjection],
    );
    final rawList = jsonDecode(encoded) as List<dynamic>;
    final restored = Task.fromJson(
      Map<String, dynamic>.from(rawList.single as Map),
    );

    expect(restored.title, 'بعد');
    expect(restored.people.single.id, 'person-home');
    expect(restored.people.single.displayName, 'رضا');
  });

  test('canonical backup and restore preserve people without a second store',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ArvinBackupManager.directoryKey: 'content://arvin-backups',
    });
    final service = _PeopleBackupService();
    final manager = ArvinBackupManager(service: service);
    final task = Task(
      id: 'backup-people',
      title: 'پشتیبان شخص',
      people: [_person('person-backup', 'نرگس')],
      taskReminders: [
        TaskReminder(
          id: 'backup-person-r1',
          title: 'پشتیبان — یادآور ۱',
          date: DateTime(2026, 10, 22, 11),
          sequence: 1,
        ),
        TaskReminder(
          id: 'backup-person-r2',
          title: 'پشتیبان — یادآور ۲',
          date: DateTime(2026, 10, 23),
          isAllDay: true,
          sequence: 2,
        ),
      ],
      nextReminderSequence: 3,
    );

    await manager.backupCanonicalTasks(<Task>[task]);
    final rawTasks = service.writtenPayload!['tasks'] as List<dynamic>;
    service.restoreDocument = <String, dynamic>{
      'type': ArvinBackupService.backupType,
      'formatVersion': ArvinBackupService.backupFormatVersion,
      'tasks': rawTasks,
    };

    final restored = await manager.restoreCanonicalTasks();
    final restoredTask = restored!.single;

    expect(restoredTask.people.single.id, 'person-backup');
    expect(restoredTask.people.single.displayName, 'نرگس');
    expect(restoredTask.taskReminders.map((item) => item.id), [
      'backup-person-r1',
      'backup-person-r2',
    ]);
    expect(restoredTask.taskReminders.last.isAllDay, isTrue);
    expect(restoredTask.nextReminderSequence, 3);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(TaskStore.key), isNull);
  });
}
