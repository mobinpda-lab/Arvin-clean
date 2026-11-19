import 'dart:convert';
import 'dart:io';

import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_service.dart';

import 'package:arvin/models/person_reference.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/g1_drift_schema.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';


class _MemoryBackupService extends ArvinBackupService {
  Map<String, dynamic>? writtenPayload;

  @override
  String createBackupFileName(DateTime dateTime) => 'person-directory-backup.json';

  @override
  Future<void> writeBackup({
    required String directoryUri,
    required Map<String, dynamic> payload,
    required String fileName,
    bool uploadToCloud = true,
    String? encryptionPassphrase,
  }) async {
    // Simulate the JSON serialization boundary of the portable backup file.
    writtenPayload = Map<String, dynamic>.from(
      jsonDecode(jsonEncode(payload)) as Map,
    );
  }

  @override
  Future<Map<String, dynamic>?> readBackup({String? passphrase}) async =>
      writtenPayload == null ? null : Map<String, dynamic>.from(writtenPayload!);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('explicit Person Directory removal survives reopen while Task and Follow-up history remains', () async {
    final directory = await Directory.systemTemp.createTemp('arvin-person-exclusion-');
    final file = File('${directory.path}/arvin.sqlite');
    addTearDown(() => directory.delete(recursive: true));

    final person = PersonReference(
      id: 'person-directory-exclusion-stable',
      displayName: 'شخص با شناسه پایدار',
    );

    var database = NativeDatabase(file);
    try {
      final store = TaskStore(executor: database);
      await store.savePeopleDirectory(<PersonReference>[person]);
      await store.save(<Task>[
        Task(
          id: 'task-person-directory-exclusion',
          title: 'کار با شخص',
          people: <PersonReference>[person],
          followUps: <FollowUp>[
            FollowUp(
              id: 'follow-up-person-directory-exclusion',
              dateTime: DateTime(2026, 11, 19, 9),
              personIds: <String>[person.id],
            ),
          ],
        ),
      ]);

      await store.savePeopleDirectory(const <PersonReference>[]);
      expect(await store.loadPeopleDirectory(), isEmpty);

      final retained = (await store.load()).single;
      expect(retained.people.single.id, person.id);
      expect(retained.people.single.displayName, person.displayName);
      expect(retained.followUps.single.id, 'follow-up-person-directory-exclusion');
      expect(retained.followUps.single.personIds, <String>[person.id]);

      final exclusions = await database.runSelect(
        'SELECT person_id FROM person_directory_exclusions',
        const [],
      );
      expect(exclusions.map((row) => row['person_id']), <String>[person.id]);
      final taskRelationCount = await database.runSelect(
        'SELECT COUNT(*) AS row_count FROM task_people WHERE task_id = ? AND person_id = ?',
        <Object?>['task-person-directory-exclusion', person.id],
      );
      final followUpRelationCount = await database.runSelect(
        'SELECT COUNT(*) AS row_count FROM follow_up_people WHERE follow_up_id = ? AND person_id = ?',
        <Object?>['follow-up-person-directory-exclusion', person.id],
      );
      expect(taskRelationCount.single['row_count'], 1);
      expect(followUpRelationCount.single['row_count'], 1);
    } finally {
      await database.close();
    }

    // Reopen and repeat schema installation. The excluded identity must not be
    // silently rehydrated from task_people or follow_up_people.
    database = NativeDatabase(file);
    try {
      await G1DriftSchema.install(database);
      await G1DriftSchema.install(database);
      final reopenedStore = TaskStore(executor: database);
      expect(await reopenedStore.loadPeopleDirectory(), isEmpty);

      final retained = (await reopenedStore.load()).single;
      expect(retained.people.single.id, person.id);
      expect(retained.followUps.single.personIds, <String>[person.id]);
      final taskRelationCount = await database.runSelect(
        'SELECT COUNT(*) AS row_count FROM task_people WHERE task_id = ? AND person_id = ?',
        <Object?>['task-person-directory-exclusion', person.id],
      );
      final followUpRelationCount = await database.runSelect(
        'SELECT COUNT(*) AS row_count FROM follow_up_people WHERE follow_up_id = ? AND person_id = ?',
        <Object?>['follow-up-person-directory-exclusion', person.id],
      );
      expect(taskRelationCount.single['row_count'], 1);
      expect(followUpRelationCount.single['row_count'], 1);

      // Explicit re-add is the only operation that clears the exclusion.
      await reopenedStore.savePeopleDirectory(<PersonReference>[person]);
      expect((await reopenedStore.loadPeopleDirectory()).single.id, person.id);

      final integrity = await database.runSelect('PRAGMA integrity_check', const []);
      final foreignKeys = await database.runSelect('PRAGMA foreign_key_check', const []);
      expect(integrity.single.values.first, 'ok');
      expect(foreignKeys, isEmpty);
    } finally {
      await database.close();
    }

    // A final fresh executor proves re-addition and historical relations are durable.
    database = NativeDatabase(file);
    try {
      final finalStore = TaskStore(executor: database);
      expect((await finalStore.loadPeopleDirectory()).single.id, person.id);
      final retained = (await finalStore.load()).single;
      expect(retained.people.single.id, person.id);
      expect(retained.followUps.single.personIds, <String>[person.id]);
    } finally {
      await database.close();
    }
  });

  test('Backup and fresh file-backed Restore preserve Person exclusion and historical links', () async {
    final sourceDirectory = await Directory.systemTemp.createTemp('arvin-person-backup-source-');
    final restoreDirectory = await Directory.systemTemp.createTemp('arvin-person-backup-restore-');
    addTearDown(() => sourceDirectory.delete(recursive: true));
    addTearDown(() => restoreDirectory.delete(recursive: true));
    final sourceFile = File('${sourceDirectory.path}/source.sqlite');
    final restoreFile = File('${restoreDirectory.path}/restored.sqlite');

    final person = PersonReference(
      id: 'person-backup-exclusion-stable',
      displayName: 'شخص حذف‌شده در دفترچه',
    );
    final task = Task(
      id: 'task-backup-exclusion',
      title: 'کار با ارتباط تاریخی',
      people: <PersonReference>[person],
      followUps: <FollowUp>[
        FollowUp(
          id: 'follow-up-backup-exclusion',
          dateTime: DateTime(2026, 11, 19, 9),
          personIds: <String>[person.id],
        ),
      ],
    );

    final backupService = _MemoryBackupService();
    final backupManager = ArvinBackupManager(service: backupService);
    await backupManager.setDirectory('content://arvin-test-backups');

    var sourceDatabase = NativeDatabase(sourceFile);
    try {
      final sourceStore = TaskStore(executor: sourceDatabase);
      await sourceStore.savePeopleDirectory(<PersonReference>[person]);
      await sourceStore.save(<Task>[task]);
      await sourceStore.savePeopleDirectory(const <PersonReference>[]);
      expect(await sourceStore.loadPeopleDirectory(), isEmpty);

      await backupManager.backupCanonicalTasks(
        await sourceStore.load(),
        people: await sourceStore.loadPeopleDirectory(),
      );
      expect(backupService.writtenPayload?['peopleDirectory'], isEmpty);
    } finally {
      await sourceDatabase.close();
    }

    final candidate = await backupManager.restoreCanonicalBackup();
    expect(candidate, isNotNull);
    expect(candidate!.hasPeople, isTrue);
    expect(candidate.people, isEmpty);
    expect(candidate.tasks.single.people.single.id, person.id);
    expect(candidate.tasks.single.followUps.single.personIds, <String>[person.id]);

    var restoreDatabase = NativeDatabase(restoreFile);
    try {
      final restoreStore = TaskStore(executor: restoreDatabase);
      // Match canonical restore order: Tasks first, then the optional directory.
      await restoreStore.save(candidate.tasks);
      if (candidate.hasPeople) {
        await restoreStore.savePeopleDirectory(candidate.people ?? const <PersonReference>[]);
      }
      expect(await restoreStore.loadPeopleDirectory(), isEmpty);
      final restored = (await restoreStore.load()).single;
      expect(restored.people.single.id, person.id);
      expect(restored.followUps.single.id, 'follow-up-backup-exclusion');
      expect(restored.followUps.single.personIds, <String>[person.id]);

      final exclusions = await restoreDatabase.runSelect(
        'SELECT person_id FROM person_directory_exclusions WHERE person_id = ?',
        <Object?>[person.id],
      );
      expect(exclusions, hasLength(1));
    } finally {
      await restoreDatabase.close();
    }

    // A real close/reopen of the restored SQLite file must not rehydrate the
    // excluded Person from Task or Follow-up history.
    restoreDatabase = NativeDatabase(restoreFile);
    try {
      await G1DriftSchema.install(restoreDatabase);
      await G1DriftSchema.install(restoreDatabase);
      final reopenedStore = TaskStore(executor: restoreDatabase);
      expect(await reopenedStore.loadPeopleDirectory(), isEmpty);
      final restored = (await reopenedStore.load()).single;
      expect(restored.people.single.id, person.id);
      expect(restored.followUps.single.personIds, <String>[person.id]);

      final taskRelationCount = await restoreDatabase.runSelect(
        'SELECT COUNT(*) AS row_count FROM task_people WHERE task_id = ? AND person_id = ?',
        <Object?>['task-backup-exclusion', person.id],
      );
      final followUpRelationCount = await restoreDatabase.runSelect(
        'SELECT COUNT(*) AS row_count FROM follow_up_people WHERE follow_up_id = ? AND person_id = ?',
        <Object?>['follow-up-backup-exclusion', person.id],
      );
      expect(taskRelationCount.single['row_count'], 1);
      expect(followUpRelationCount.single['row_count'], 1);

      // Explicit same-ID re-add clears only the directory exclusion.
      await reopenedStore.savePeopleDirectory(<PersonReference>[person]);
      expect((await reopenedStore.loadPeopleDirectory()).single.id, person.id);
      final taskRowsAfterReadd = await restoreDatabase.runSelect(
        'SELECT COUNT(*) AS row_count FROM task_people WHERE task_id = ? AND person_id = ?',
        <Object?>['task-backup-exclusion', person.id],
      );
      final followUpRowsAfterReadd = await restoreDatabase.runSelect(
        'SELECT COUNT(*) AS row_count FROM follow_up_people WHERE follow_up_id = ? AND person_id = ?',
        <Object?>['follow-up-backup-exclusion', person.id],
      );
      expect(taskRowsAfterReadd.single['row_count'], 1);
      expect(followUpRowsAfterReadd.single['row_count'], 1);
    } finally {
      await restoreDatabase.close();
    }
  });

}
