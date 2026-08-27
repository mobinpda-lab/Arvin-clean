import 'dart:convert';

import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_service.dart';
import 'package:arvin/models/person_reference.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_migration_writer.dart';
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
      throwsFormatException,
    );
    expect(
      () => Task.fromJson(<String, dynamic>{
        'id': 'bad-person',
        'title': 'bad',
        'people': [
          <String, dynamic>{'id': 'person-1'},
        ],
      }),
      throwsFormatException,
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
      throwsFormatException,
    );
  });

  test('TaskStore uses the existing key and round-trips people', () async {
    final store = TaskStore();
    await store.save(<Task>[
      Task(
        id: 'store-people',
        title: 'ذخیره شخص',
        people: [_person('person-store', 'مریم')],
      ),
    ]);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), contains(TaskStore.key));
    expect(prefs.getKeys(), hasLength(1));

    final loaded = await store.load();
    expect(loaded.single.people.single.id, 'person-store');
    expect(loaded.single.people.single.displayName, 'مریم');
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
    );

    await manager.backupCanonicalTasks(<Task>[task]);
    final rawTasks = service.writtenPayload!['tasks'] as List<dynamic>;
    service.restoreDocument = <String, dynamic>{
      'type': ArvinBackupService.backupType,
      'formatVersion': ArvinBackupService.backupFormatVersion,
      'tasks': rawTasks,
    };

    final restored = await manager.restoreCanonicalTasks();

    expect(restored, isNotNull);
    expect(restored!.single.people.single.id, 'person-backup');
    expect(restored.single.people.single.displayName, 'نرگس');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(TaskStore.key), isNull);
  });
}
