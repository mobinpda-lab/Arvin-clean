import 'dart:io';

import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_service.dart';
import 'package:arvin/models/person_directory_exclusion.dart';
import 'package:arvin/models/person_reference.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeBackupService extends ArvinBackupService {
  Map<String, dynamic>? writtenPayload;
  Map<String, dynamic>? restoreDocument;

  @override
  String createBackupFileName(DateTime dateTime) => 'person-exclusion-backup.json';

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

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      ArvinBackupManager.directoryKey: 'content://arvin-backups',
    });
  });

  test('file-backed backup and independent restore preserve Person exclusions and history', () async {
    final sourceDirectory = await Directory.systemTemp.createTemp(
      'arvin-person-exclusion-source-',
    );
    final targetDirectory = await Directory.systemTemp.createTemp(
      'arvin-person-exclusion-target-',
    );
    addTearDown(() => sourceDirectory.delete(recursive: true));
    addTearDown(() => targetDirectory.delete(recursive: true));

    final sourceDatabase = NativeDatabase(
      File('${sourceDirectory.path}/source.sqlite'),
    );
    final sourceStore = TaskStore(executor: sourceDatabase);
    final person = PersonReference(
      id: 'person-portable-exclusion',
      displayName: 'شخص تاریخی',
    );
    await sourceStore.savePeopleDirectory(<PersonReference>[person]);
    await sourceStore.save(<Task>[
      Task(
        id: 'task-portable-exclusion',
        title: 'کار با ارتباط تاریخی',
        people: <PersonReference>[person],
        followUps: [
          FollowUp(
            id: 'follow-up-portable-exclusion',
            dateTime: DateTime(2026, 11, 18, 10),
            note: 'پیگیری باید باقی بماند',
            personIds: <String>[person.id],
          ),
        ],
      ),
    ]);
    await sourceStore.savePeopleDirectory(const <PersonReference>[]);

    final sourceTasks = await sourceStore.load();
    final sourcePeople = await sourceStore.loadPeopleDirectory();
    final sourceExclusions = await sourceStore.loadPersonDirectoryExclusions();
    expect(sourcePeople, isEmpty);
    expect(sourceExclusions, hasLength(1));
    expect(sourceTasks.single.people.single.isDeleted, isTrue);

    final service = _FakeBackupService();
    final manager = ArvinBackupManager(service: service);
    await manager.backupCanonicalTasks(
      sourceTasks,
      people: sourcePeople,
      personDirectoryExclusions: sourceExclusions,
    );
    expect(service.writtenPayload?['personDirectoryExclusions'], hasLength(1));

    final encoded = ArvinBackupService.encodeBackupDocument(
      service.writtenPayload!,
    );
    service.restoreDocument = ArvinBackupService.validateBackupDocument(encoded);
    final candidate = await manager.restoreCanonicalBackup();
    expect(candidate, isNotNull);
    expect(candidate!.hasPersonDirectoryExclusions, isTrue);

    final targetDatabase = NativeDatabase(
      File('${targetDirectory.path}/target.sqlite'),
    );
    final targetStore = TaskStore(executor: targetDatabase);
    await targetStore.load();
    final reconciled = ArvinBackupManager.reconcilePersonDirectoryById(
      currentPeople: await targetStore.loadPeopleDirectory(),
      currentExclusions: await targetStore.loadPersonDirectoryExclusions(),
      backupPeople: candidate.people,
      backupExclusions: candidate.personDirectoryExclusions,
    );
    await targetStore.savePeopleDirectory(reconciled.people);
    await targetStore.replacePersonDirectoryExclusions(reconciled.exclusions);
    await targetStore.save(candidate.tasks);

    expect(await targetStore.loadPeopleDirectory(), isEmpty);
    final restoredExclusions = await targetStore.loadPersonDirectoryExclusions();
    expect(restoredExclusions, hasLength(1));
    expect(restoredExclusions.single.personId, person.id);

    final restoredTask = (await targetStore.load()).single;
    expect(restoredTask.people, hasLength(1));
    expect(restoredTask.people.single.id, person.id);
    expect(restoredTask.people.single.isDeleted, isTrue);
    expect(restoredTask.followUps.single.personIds, <String>[person.id]);

    final taskLinks = await targetDatabase.runSelect(
      'SELECT person_id FROM task_persons WHERE task_id = ?',
      const <Object?>['task-portable-exclusion'],
    );
    final followUpLinks = await targetDatabase.runSelect(
      'SELECT person_id FROM follow_up_record_people WHERE follow_up_id = ?',
      const <Object?>['follow-up-portable-exclusion'],
    );
    expect(taskLinks, hasLength(1));
    expect(followUpLinks, hasLength(1));

    final integrity = await targetDatabase.runSelect('PRAGMA integrity_check', const []);
    expect(integrity.single['integrity_check'], 'ok');
    final foreignKeys = await targetDatabase.runSelect('PRAGMA foreign_key_check', const []);
    expect(foreignKeys, isEmpty);

    await sourceDatabase.close();
    await targetDatabase.close();
  });
}
