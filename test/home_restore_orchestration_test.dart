import 'dart:async';

import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_schedule.dart';
import 'package:arvin/backup_service.dart';
import 'package:arvin/main.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/app_settings_service.dart';
import 'package:arvin/services/calendar_sync_plan_service.dart';
import 'package:arvin/services/external_calendar_link_store.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _HomeRestoreBackupService extends ArvinBackupService {
  _HomeRestoreBackupService(this.document);

  final Map<String, dynamic> document;
  int writeCount = 0;
  int readCount = 0;

  @override
  String createBackupFileName(DateTime dateTime) => 'emergency-backup.json';

  @override
  Future<void> writeBackup({
    required String directoryUri,
    required Map<String, dynamic> payload,
    required String fileName,
    bool uploadToCloud = true,
    String? encryptionPassphrase,
  }) async {
    writeCount += 1;
  }

  @override
  Future<Map<String, dynamic>?> readBackup({String? passphrase}) async {
    readCount += 1;
    return document;
  }

  @override
  Future<Map<String, dynamic>?> readBackupWithPassphrasePrompt({
    required Future<String?> Function() requestPassphrase,
  }) async {
    readCount += 1;
    return document;
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ArvinBackupManager.directoryKey: 'content://arvin-backups',
    });
    await TaskStore.resetTestDatabase();
    await ProjectStore.resetTestDatabase();
  });

  tearDown(() async {
    await TaskStore.resetTestDatabase();
    await ProjectStore.resetTestDatabase();
  });

  testWidgets(
    'Home restore rolls back Task, Project, calendar links and settings after a late failure',
    (tester) async {
      // Exercise the production topology: both stores share one SQLite executor.
      // All IDs in these snapshots are synthetic; no payload/settings are logged.
      final executor = NativeDatabase.memory();
      final restoreFinished = Completer<void>();
      final taskStore = TaskStore(executor: executor);
      final projectStore = ProjectStore(executor: executor);
      final operationId = 'restore-forensics-${DateTime.now().microsecondsSinceEpoch}';
      Future<Map<String, Object>> sqliteSnapshot(String stage) async {
        final taskRows = await executor.runSelect(
          'SELECT id FROM tasks ORDER BY id',
          const [],
        );
        final projectRows = await executor.runSelect(
          'SELECT id FROM projects ORDER BY id',
          const [],
        );
        final relationRows = await executor.runSelect(
          'SELECT project_id, task_id, ordinal FROM project_items ORDER BY project_id, ordinal',
          const [],
        );
        final snapshot = <String, Object>{
          'taskIds': taskRows.map((row) => row['id'] as String).toList(),
          'projectIds': projectRows.map((row) => row['id'] as String).toList(),
          'projectItems': relationRows.map((row) => <String, Object?>{
            'projectId': row['project_id']!,
            'taskId': row['task_id']!,
            'ordinal': row['ordinal']!,
          }).toList(),
        };
        // ignore: avoid_print
        print('ARVIN_RESTORE_FORENSICS op=$operationId stage=$stage snapshot=$snapshot');
        return snapshot;
      }
      try {
      await taskStore.save([
        Task.fromJson(<String, dynamic>{
          'id': 'local-task',
          'title': 'کار محلی',
        }),
      ]);
      await projectStore.save([
        ProjectPlan(
          id: 'local-project',
          title: 'پروژه محلی',
          itemIds: const <String>['local-task'],
        ),
      ]);
      final localLink = ExternalCalendarEventLink(
        reminderId: 'task-due:local-task',
        calendarId: 'local-calendar',
        eventId: 'local-event',
        lastSyncedFingerprint: 'local-fingerprint',
      );
      await ExternalCalendarLinkStore().save([localLink]);
      await taskStore.createCategory('دسته محلی');
      await taskStore.createTag('برچسب محلی');
      final initialSnapshot = await sqliteSnapshot('before-restore');
      expect(initialSnapshot['taskIds'], <String>['local-task']);
      expect(initialSnapshot['projectIds'], <String>['local-project']);
      expect(initialSnapshot['projectItems'], <Map<String, Object?>>[
        <String, Object?>{'projectId': 'local-project', 'taskId': 'local-task', 'ordinal': 0},
      ]);

      final settingsService = AppSettingsService();
      final settingsBefore = await settingsService.load();
      final scheduleBefore = await BackupSchedule.load();
      final backupService = _HomeRestoreBackupService(<String, dynamic>{
        'type': ArvinBackupService.backupType,
        'formatVersion': ArvinBackupService.backupFormatVersion,
        'tasks': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'restored-task',
            'title': 'کار بازیابی‌شده',
          },
        ],
        'projects': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'restored-project',
            'title': 'پروژه بازیابی‌شده',
            'colorValue': 0xFF4A4CAB,
            'isArchived': false,
            'itemIds': <String>['restored-task'],
          },
        ],
        'calendarLinks': <Map<String, dynamic>>[
          <String, dynamic>{
            'reminderId': 'task-due:restored-task',
            'calendarId': 'restored-calendar',
            'eventId': 'restored-event',
            'lastSyncedFingerprint': 'restored-fingerprint',
          },
        ],
        'settings': <String, dynamic>{
          'themeMode': 'dark',
          'usePersianDate': false,
          'fontSize': 22.0,
          'backupSchedule': <String, dynamic>{
            'enabled': true,
            'hour': 6,
            'minute': 15,
            'frequency': 'daily',
          },
        },
        'categories': <String>['دسته بازیابی‌شده'],
        'tags': <String>['برچسب بازیابی‌شده'],
      });
      final manager = ArvinBackupManager(service: backupService);

      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            backupManager: manager,
            taskStore: taskStore,
            projectStore: projectStore,
            restoreCompletionHook: () {
              if (!restoreFinished.isCompleted) restoreFinished.complete();
            },
            restoreStageHook: (stage) async {
              await sqliteSnapshot(stage);
              if (stage == 'catalogs') {
                throw StateError('injected after catalogs');
              }
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('primary-nav-more')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('پشتیبان‌گیری'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Restore از فایل'));
      await tester.pumpAndSettle();

      expect(find.text('بازیابی اطلاعات'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'بازیابی'));
      await tester.pumpAndSettle();
      await restoreFinished.future;

      final finalSnapshot = await sqliteSnapshot('after-all-async-work');
      expect(finalSnapshot['taskIds'], <String>['local-task']);
      expect(finalSnapshot['projectIds'], <String>['local-project']);
      expect(finalSnapshot['projectItems'], <Map<String, Object?>>[
        <String, Object?>{'projectId': 'local-project', 'taskId': 'local-task', 'ordinal': 0},
      ]);
      expect(backupService.readCount, 1);
      expect(backupService.writeCount, 1);
      expect((await taskStore.load()).map((task) => task.id), ['local-task']);
      expect(await taskStore.loadCategories(), contains('دسته محلی'));
      expect(await taskStore.loadCategories(), isNot(contains('دسته بازیابی‌شده')));
      expect(await taskStore.loadTags(), contains('برچسب محلی'));
      expect(await taskStore.loadTags(), isNot(contains('برچسب بازیابی‌شده')));
      expect(
        (await projectStore.load()).map((project) => project.id),
        ['local-project'],
      );
      final restoredLinks = await ExternalCalendarLinkStore().load();
      expect(restoredLinks, hasLength(1));
      expect(restoredLinks.single.toJson(), localLink.toJson());
      expect((await settingsService.load()).fontSize, settingsBefore.fontSize);
      final scheduleAfter = await BackupSchedule.load();
      expect(scheduleAfter.enabled, scheduleBefore.enabled);
      expect(scheduleAfter.hour, scheduleBefore.hour);
      expect(scheduleAfter.minute, scheduleBefore.minute);
      expect(scheduleAfter.frequency, scheduleBefore.frequency);
      expect(
        find.text('بازیابی کامل نشد؛ اطلاعات قبلی به حالت پیشین بازگردانده شد.'),
        findsOneWidget,
      );
      } finally {
        await executor.close();
      }
    },
  );
}
