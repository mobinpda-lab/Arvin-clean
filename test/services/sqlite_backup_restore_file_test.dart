import 'dart:io';

import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_service.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/person_reference.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FileBackedBackupService extends ArvinBackupService {
  _FileBackedBackupService(this.file);

  final File file;

  @override
  String createBackupFileName(DateTime dateTime) => 'arvin-d04-backup.json';

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
    return decodeBackupBytes(
      await file.readAsBytes(),
      passphrase: passphrase,
    );
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'canonical backup restores to an independent SQLite file and survives reopen',
    () async {
      final directory =
          await Directory.systemTemp.createTemp('arvin-d04-backup-restore-');
      final sourceFile = File('${directory.path}/source.sqlite');
      final destinationFile = File('${directory.path}/restored.sqlite');
      final backupFile = File('${directory.path}/backup.json');

      NativeDatabase? sourceExecutor = NativeDatabase(sourceFile);
      NativeDatabase? destinationExecutor;
      NativeDatabase? reopenedExecutor;

      try {
        final sourceTasks = TaskStore(executor: sourceExecutor);
        final sourceProjects = ProjectStore(executor: sourceExecutor);
        final person = PersonReference(
          id: 'person-d04',
          displayName: 'شخص آزمون D04',
        );
        final task = Task(
          id: 'task-d04',
          title: 'بازیابی مستقل SQLite',
          description: 'Task، Reminder، Follow-up و Person باید باقی بمانند.',
          createdAt: DateTime(2026, 11, 1, 8),
          updatedAt: DateTime(2026, 11, 2, 9),
          category: 'دسته D04',
          tags: const ['برچسب یک', 'برچسب دو'],
          people: [person],
          taskReminders: [
            TaskReminder(
              id: 'reminder-d04',
              title: 'یادآور مستقل D04',
              date: DateTime(2026, 11, 15, 10, 30),
              sequence: 1,
            ),
          ],
          followUps: [
            FollowUp(
              id: 'follow-up-d04',
              completedAt: DateTime(2026, 11, 2, 9, 15),
              note: 'تماس با شخص آزمون',
              result: 'منتظر پاسخ',
              waitingForResponse: true,
              personIds: [person.id],
            ),
          ],
        );

        await sourceTasks.createCategory('دسته D04');
        await sourceTasks.createTag('برچسب یک');
        await sourceTasks.createTag('برچسب دو');
        await sourceTasks.save([task]);
        await sourceTasks.savePeopleDirectory([person]);
        await sourceProjects.save([
          ProjectPlan(
            id: 'project-d04',
            title: 'پروژه بازیابی D04',
            itemIds: const ['task-d04'],
          ),
        ]);

        final backupManager = ArvinBackupManager(
          service: _FileBackedBackupService(backupFile),
        );
        await backupManager.setDirectory(directory.path);
        await backupManager.backupCanonicalTasks(
          await sourceTasks.load(),
          projects: await sourceProjects.load(),
          categories: await sourceTasks.loadCategories(),
          tags: await sourceTasks.loadTags(),
          people: await sourceTasks.loadPeopleDirectory(),
        );
        expect(await backupFile.exists(), isTrue);
        expect(await backupFile.length(), greaterThan(0));

        await sourceExecutor.close();
        sourceExecutor = null;

        final candidate = await backupManager.restoreCanonicalBackup();
        expect(candidate, isNotNull);

        destinationExecutor = NativeDatabase(destinationFile);
        final destinationTasks = TaskStore(executor: destinationExecutor);
        final destinationProjects =
            ProjectStore(executor: destinationExecutor);
        await destinationTasks.save(candidate!.tasks);
        await destinationTasks.mergeCatalogs(
          categories: candidate.categories ?? const <String>[],
          tags: candidate.tags ?? const <String>[],
        );
        await destinationTasks.savePeopleDirectory(
          candidate.people ?? const <PersonReference>[],
        );
        await destinationProjects.save(
          candidate.projects,
        );

        await destinationExecutor.close();
        destinationExecutor = null;

        reopenedExecutor = NativeDatabase(destinationFile);
        final reopenedTasks = TaskStore(executor: reopenedExecutor);
        final reopenedProjects = ProjectStore(executor: reopenedExecutor);
        final restoredTasks = await reopenedTasks.load();
        expect(restoredTasks, hasLength(1));

        final restoredTask = restoredTasks.single;
        expect(restoredTask.id, 'task-d04');
        expect(restoredTask.category, 'دسته D04');
        expect(restoredTask.tags, containsAll(['برچسب یک', 'برچسب دو']));
        expect(restoredTask.taskReminders, hasLength(1));
        expect(restoredTask.taskReminders.single.id, 'reminder-d04');
        expect(restoredTask.followUps, hasLength(1));
        expect(restoredTask.followUps.single.id, 'follow-up-d04');
        expect(
          restoredTask.followUps.single.personIds,
          contains(person.id),
        );
        expect(
          restoredTask.people.map((value) => value.id),
          contains(person.id),
        );
        expect(
          (await reopenedTasks.loadPeopleDirectory()).map((value) => value.id),
          contains(person.id),
        );
        expect(
          (await reopenedProjects.load()).single.itemIds,
          contains('task-d04'),
        );

        final integrity = await reopenedExecutor.runSelect(
          'PRAGMA integrity_check',
          const [],
        );
        expect(integrity.single['integrity_check'], 'ok');
        expect(
          await reopenedExecutor.runSelect(
            'PRAGMA foreign_key_check',
            const [],
          ),
          isEmpty,
        );
        final foreignKeys = await reopenedExecutor.runSelect(
          'PRAGMA foreign_keys',
          const [],
        );
        expect(foreignKeys.single['foreign_keys'], 1);
      } finally {
        if (sourceExecutor != null) await sourceExecutor.close();
        if (destinationExecutor != null) await destinationExecutor.close();
        if (reopenedExecutor != null) await reopenedExecutor.close();
        await directory.delete(recursive: true);
      }
    },
  );
}
