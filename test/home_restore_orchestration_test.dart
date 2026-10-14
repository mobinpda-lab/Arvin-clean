import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_schedule.dart';
import 'package:arvin/backup_service.dart';
import 'package:arvin/main.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/person_reference.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/app_settings_service.dart';
import 'package:arvin/services/calendar_sync_plan_service.dart';
import 'package:arvin/services/external_calendar_link_store.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _HomeRestoreBackupService extends ArvinBackupService {
  _HomeRestoreBackupService(this.document);

  final Map<String, dynamic> document;
  int writeCount = 0;
  int readCount = 0;
  Map<String, dynamic>? writtenPayload;

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
    writtenPayload = Map<String, dynamic>.from(payload);
  }

  @override
  Future<Map<String, dynamic>?> readBackup({String? passphrase}) async {
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
    'Home restore rolls back Task, Person directory, Project, calendar links and settings after a late failure',
    (tester) async {
      final taskStore = TaskStore();
      final localPerson = PersonReference(
        id: 'local-person',
        displayName: 'شخص محلی',
      );
      await taskStore.savePersonDirectoryEntry(localPerson);
      await taskStore.save([
        Task(
          id: 'local-task',
          title: 'کار محلی',
          followUps: [
            FollowUp(
              id: 'local-follow-up',
              dateTime: DateTime(2026, 10, 14, 9),
              waitingForResponse: true,
              personIds: [localPerson.id],
            ),
          ],
        ),
      ]);
      await ProjectStore().save([
        ProjectPlan(
          id: 'local-project',
          title: 'پروژه محلی',
          itemIds: const <String>[],
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

      final settingsService = AppSettingsService();
      final settingsBefore = await settingsService.load();
      final scheduleBefore = await BackupSchedule.load();
      final backupService = _HomeRestoreBackupService(<String, dynamic>{
        'type': ArvinBackupService.backupType,
        'formatVersion': ArvinBackupService.backupFormatVersion,
        'tasks': <Map<String, dynamic>>[
          Task(
            id: 'restored-task',
            title: 'کار بازیابی‌شده',
            followUps: [
              FollowUp(
                id: 'restored-follow-up',
                dateTime: DateTime(2026, 10, 15, 9),
                waitingForResponse: true,
                personIds: const ['restored-person'],
              ),
            ],
          ).toJson(),
        ],
        'people': <Map<String, dynamic>>[
          PersonReference(
            id: 'restored-person',
            displayName: 'شخص بازیابی‌شده',
          ).toJson(),
        ],
        'projects': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'restored-project',
            'title': 'پروژه بازیابی‌شده',
            'colorValue': 0xFF4A4CAB,
            'isArchived': false,
            'itemIds': <String>[],
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
            restoreStageHook: (stage) async {
              if (stage == 'catalogs') throw StateError('injected after catalogs');
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

      expect(backupService.readCount, 1);
      expect(backupService.writeCount, 1);
      expect(
        ((backupService.writtenPayload!['people'] as List<dynamic>)
            .cast<Map<String, dynamic>>())
            .map((person) => person['id']),
        ['local-person'],
      );
      final restoredTasks = await taskStore.load();
      expect(restoredTasks.map((task) => task.id), ['local-task']);
      expect(restoredTasks.single.followUps.single.id, 'local-follow-up');
      expect(restoredTasks.single.followUps.single.personIds, ['local-person']);
      expect(
        (await taskStore.loadPeopleDirectory()).map((person) => person.id),
        ['local-person'],
      );
      expect(await taskStore.loadCategories(), contains('دسته محلی'));
      expect(await taskStore.loadCategories(), isNot(contains('دسته بازیابی‌شده')));
      expect(await taskStore.loadTags(), contains('برچسب محلی'));
      expect(await taskStore.loadTags(), isNot(contains('برچسب بازیابی‌شده')));
      expect(
        (await ProjectStore().load()).map((project) => project.id),
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
    },
  );
}
