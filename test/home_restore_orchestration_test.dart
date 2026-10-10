import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_schedule.dart';
import 'package:arvin/backup_service.dart';
import 'package:arvin/main.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/app_settings_service.dart';
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
      final taskStore = TaskStore();
      await taskStore.save([
        Task.fromJson(<String, dynamic>{
          'id': 'local-task',
          'title': 'کار محلی',
        }),
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
            'enabled': 'invalid-late-stage-value',
          },
        },
      });
      final manager = ArvinBackupManager(service: backupService);

      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(backupManager: manager),
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
      expect((await taskStore.load()).map((task) => task.id), ['local-task']);
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
