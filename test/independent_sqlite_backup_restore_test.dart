import 'dart:io';
import 'dart:typed_data';

import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_service.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FileBackedBackupService extends ArvinBackupService {
  _FileBackedBackupService(this.file);

  final File file;

  @override
  String createBackupFileName(DateTime dateTime) => 'database-a-backup.json';

  @override
  Future<void> writeBackup({
    required String directoryUri,
    required Map<String, dynamic> payload,
    required String fileName,
    bool uploadToCloud = true,
    String? encryptionPassphrase,
  }) async {
    final bytes = await prepareBackupBytes(
      payload,
      passphrase: encryptionPassphrase,
    );
    await file.writeAsBytes(bytes, flush: true);
  }

  @override
  Future<Map<String, dynamic>?> readBackup({String? passphrase}) async {
    if (!await file.exists()) return null;
    final bytes = await file.readAsBytes();
    return decodeBackupBytes(
      Uint8List.fromList(bytes),
      passphrase: passphrase,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('independent SQLite A to file backup to SQLite B survives repeated restore and rollback',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ArvinBackupManager.directoryKey: 'file-backed-independent-restore',
    });

    final directory = await Directory.systemTemp.createTemp(
      'arvin-independent-backup-restore-',
    );
    final databaseAFile = File('${directory.path}/database-a.sqlite');
    final databaseBFile = File('${directory.path}/database-b.sqlite');
    final backupFile = File('${directory.path}/database-a-backup.json');
    var databaseA = NativeDatabase(databaseAFile);
    var databaseB = NativeDatabase(databaseBFile);

    try {
      expect(databaseAFile.path, isNot(databaseBFile.path));

      final storeA = TaskStore(executor: databaseA);
      const taskId = 'independent-backup-task';
      const personId = 'independent-backup-person';
      const followUpId = 'independent-backup-follow-up';
      final task = Task.fromJson(<String, dynamic>{
        'id': taskId,
        'title': 'داده مستقل پایگاه A',
        'description': 'رابطه‌ها و فیلدهای nullable باید حفظ شوند',
        'category': 'پروژه مستقل',
        'tags': <String>['پشتیبان'],
        'checklist': <String>['مرحله اول', 'مرحله دوم'],
        'notebookKind': null,
        'futureTaskField': <String, dynamic>{
          'preserve': true,
          'revision': 7,
        },
        'templateTaskId': null,
        'focusDate': null,
        'recurrence': null,
        'people': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': personId,
            'displayName': 'شخص پشتیبان',
          },
        ],
        'followUps': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': followUpId,
            'completedAt': '2026-11-20T07:00:00.000',
            'futureFollowUpField': <String, dynamic>{
              'preserve': 'historical-record',
              'revision': 3,
            },
            'title': 'پیگیری ثبت‌شده',
            'note': 'تاریخچه و رابطه شخص',
            'completed': false,
            'waitingForResponse': true,
            'personIds': <String>[personId],
          },
        ],
      });

      await storeA.save(<Task>[task]);
      await storeA.createCategory('دسته مستقل بدون اتکا به UI');
      await storeA.createTag('برچسب مستقل');
      await storeA.savePeopleDirectory(task.people);

      final sourceTasks = await storeA.load();
      expect(sourceTasks, hasLength(1));
      expect(sourceTasks.single.id, taskId);
      expect(sourceTasks.single.followUps.single.id, followUpId);
      expect(
        sourceTasks.single.toJson()['futureTaskField'],
        <String, dynamic>{'preserve': true, 'revision': 7},
      );
      expect(
        sourceTasks.single.followUps.single.toJson()['futureFollowUpField'],
        <String, dynamic>{
          'preserve': 'historical-record',
          'revision': 3,
        },
      );

      final backupService = _FileBackedBackupService(backupFile);
      final manager = ArvinBackupManager(service: backupService);
      final backupName = await manager.backupCanonicalTasks(
        sourceTasks,
        categories: await storeA.loadCategories(),
        tags: await storeA.loadTags(),
        people: await storeA.loadPeopleDirectory(),
      );

      expect(backupName, 'database-a-backup.json');
      expect(await backupFile.exists(), isTrue);
      expect(await backupFile.length(), greaterThan(0));

      // Database B is a separate SQLite file and starts with no user records.
      final storeB = TaskStore(executor: databaseB);
      expect(await storeB.load(), isEmpty);
      final candidate = await manager.restoreCanonicalBackup();
      expect(candidate, isNotNull);
      final firstCandidate = candidate!;
      expect(firstCandidate.tasks, hasLength(1));
      expect(firstCandidate.tasks.single.id, taskId);

      Future<void> applyCandidate(
        CanonicalBackupCandidate candidateToApply,
      ) async {
        await storeB.save(candidateToApply.tasks);
        await storeB.mergeCatalogs(
          categories: candidateToApply.categories ?? const <String>[],
          tags: candidateToApply.tags ?? const <String>[],
        );
        if (candidateToApply.people != null) {
          await storeB.savePeopleDirectory(candidateToApply.people!);
        }
      }

      await applyCandidate(firstCandidate);

      Future<void> verifyDatabaseB() async {
        final restoredTasks = await storeB.load();
        expect(restoredTasks, hasLength(1));
        final restored = restoredTasks.single;
        expect(restored.id, taskId);
        expect(restored.title, 'داده مستقل پایگاه A');
        expect(restored.checklist, <String>['مرحله اول', 'مرحله دوم']);
        expect(restored.followUps, hasLength(1));
        expect(restored.followUps.single.id, followUpId);
        expect(restored.followUps.single.personIds, <String>[personId]);
        expect(restored.people.map((person) => person.id), <String>[personId]);
        expect(
          restored.toJson()['futureTaskField'],
          <String, dynamic>{'preserve': true, 'revision': 7},
        );
        expect(
          restored.followUps.single.toJson()['futureFollowUpField'],
          <String, dynamic>{
            'preserve': 'historical-record',
            'revision': 3,
          },
        );

        // Compare the complete canonical Task envelope, not only selected
        // fields, so unknown/nullable/model-owned data cannot silently drift.
        expect(restored.toJson(), sourceTasks.single.toJson());
        final portable = restored.toJson();
        for (final key in const <String>[
          'notebookKind',
          'templateTaskId',
          'focusDate',
          'recurrence',
        ]) {
          expect(portable.containsKey(key), isTrue, reason: '$key was omitted');
          expect(portable[key], isNull, reason: '$key changed');
        }

        expect(await storeB.loadCategories(), contains('دسته مستقل بدون اتکا به UI'));
        expect(await storeB.loadTags(), contains('برچسب مستقل'));
        expect(
          (await storeB.loadPeopleDirectory()).map((person) => person.id),
          contains(personId),
        );

        final taskPeople = await databaseB.runSelect(
          'SELECT person_id FROM task_persons WHERE task_id = ?',
          <Object?>[taskId],
        );
        expect(taskPeople.map((row) => row['person_id']), <String>[personId]);
        final followUpPeople = await databaseB.runSelect(
          'SELECT person_id FROM follow_up_record_people WHERE follow_up_id = ?',
          <Object?>[followUpId],
        );
        expect(followUpPeople.map((row) => row['person_id']), <String>[personId]);

        final integrity = await databaseB.runSelect(
          'PRAGMA integrity_check',
          const [],
        );
        expect(integrity.single.values.single, 'ok');
        expect(
          await databaseB.runSelect('PRAGMA foreign_key_check', const []),
          isEmpty,
        );
      }

      await verifyDatabaseB();

      // A second restore into the same target must remain identity-stable and
      // must not duplicate Tasks, Follow-ups, or relation rows.
      final secondCandidate = await manager.restoreCanonicalBackup();
      expect(secondCandidate, isNotNull);
      await applyCandidate(secondCandidate!);
      await verifyDatabaseB();
      final taskCount = await databaseB.runSelect(
        'SELECT COUNT(*) AS count FROM tasks',
        const [],
      );
      final followUpCount = await databaseB.runSelect(
        'SELECT COUNT(*) AS count FROM follow_up_records',
        const [],
      );
      expect((taskCount.single['count'] as num).toInt(), 1);
      expect((followUpCount.single['count'] as num).toInt(), 1);
      final taskPersonCount = await databaseB.runSelect(
        'SELECT COUNT(*) AS count FROM task_persons',
        const [],
      );
      final followUpPersonCount = await databaseB.runSelect(
        'SELECT COUNT(*) AS count FROM follow_up_record_people',
        const [],
      );
      expect((taskPersonCount.single['count'] as num).toInt(), 1);
      expect((followUpPersonCount.single['count'] as num).toInt(), 1);

      // Inject a failure after a real write to Database B and require the
      // rollback path to restore the complete prior Task snapshot.
      final beforeFailure = await storeB.load();
      await expectLater(
        runRestoreWithRollback<void>(
          recoveryBackup: backupFile.path,
          apply: () async {
            await storeB.save(<Task>[
              Task(id: 'failed-candidate-task', title: 'نباید باقی بماند'),
            ]);
            throw StateError('injected failure after Database B write');
          },
          rollback: () => storeB.save(beforeFailure),
        ),
        throwsA(
          isA<RestoreExecutionFailure>().having(
            (failure) => failure.rolledBack,
            'rolledBack',
            isTrue,
          ),
        ),
      );
      await verifyDatabaseB();
      final failedCandidateRows = await databaseB.runSelect(
        'SELECT id FROM tasks WHERE id = ?',
        const <Object?>['failed-candidate-task'],
      );
      expect(failedCandidateRows, isEmpty);
    } finally {
      await databaseA.close();
      await databaseB.close();
      await directory.delete(recursive: true);
    }
  });
}
