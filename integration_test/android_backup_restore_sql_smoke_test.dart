import 'dart:convert';
import 'dart:io';

import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_page.dart';
import 'package:arvin/backup_service.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/calendar_sync_plan_service.dart';
import 'package:arvin/services/external_calendar_link_store.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RuntimeBackupService extends ArvinBackupService {
  Map<String, dynamic>? document;
  int writes = 0;

  @override
  String createBackupFileName(DateTime dateTime) => 'runtime-backup.json';

  @override
  Future<void> writeBackup({
    required String directoryUri,
    required Map<String, dynamic> payload,
    required String fileName,
    bool uploadToCloud = true,
    String? encryptionPassphrase,
  }) async {
    writes += 1;
    document = Map<String, dynamic>.from(payload);
  }

  @override
  Future<Map<String, dynamic>?> readBackup({String? passphrase}) async =>
      document;
}

class _FileBackedBackupService extends ArvinBackupService {
  _FileBackedBackupService(this.file);

  final File file;

  @override
  String createBackupFileName(DateTime dateTime) => file.uri.pathSegments.last;

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
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('canonical SQL migration and backup/restore runtime smoke',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ArvinBackupManager.directoryKey: 'content://arvin-runtime-smoke',
      TaskStore.key: jsonEncode(<Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'legacy-runtime',
          'title': 'کار مهاجرتی',
          'description': 'داده قدیمی',
          'tags': <String>['مهم'],
          'category': 'فروش',
          'followUps': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'fu-runtime',
              'dateTime': '2026-09-20T10:00:00.000Z',
              'note': 'پیگیری قدیمی',
              'completed': true,
            },
          ],
        },
      ]),
    });

    final store = TaskStore();
    final migrated = await store.load();
    expect(migrated.single.id, 'legacy-runtime');
    expect(migrated.single.followUps.single.id, 'fu-runtime');
    expect(migrated.single.tags, <String>['مهم']);
    expect(migrated.single.category, 'فروش');

    // Complete the canonical cycle before backup: mutate through SQL, then
    // read from a fresh TaskStore instance to prove restart-like persistence.
    migrated.single.title = 'کار مهاجرتی ویرایش‌شده';
    migrated.single.checklist = <String>['مرحله ذخیره'];
    await store.save(migrated);
    final freshStore = TaskStore();
    final afterSave = await freshStore.load();
    expect(afterSave.single.id, 'legacy-runtime');
    expect(afterSave.single.title, 'کار مهاجرتی ویرایش‌شده');
    expect(afterSave.single.tags, <String>['مهم']);
    expect(afterSave.single.category, 'فروش');
    expect(afterSave.single.checklist, <String>['مرحله ذخیره']);

    final service = _RuntimeBackupService();
    final manager = ArvinBackupManager(service: service);

    await tester.pumpWidget(
      MaterialApp(
        home: BackupPage(
          manager: manager,
          loadTasks: () async =>
              (await freshStore.load()).map((task) => task.toJson()).toList(),
          replaceTasks: (rawTasks) async {
            await store.save(
              rawTasks.map((raw) => Task.fromJson(raw)).toList(growable: false),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('create_backup_button')));
    await tester.pumpAndSettle();
    expect(service.writes, 1);
    expect(service.document?['tasks'], isNotEmpty);

    service.document = <String, dynamic>{
      'type': ArvinBackupService.backupType,
      'formatVersion': ArvinBackupService.backupFormatVersion,
      'tasks': <Map<String, dynamic>>[
        Task(
          id: 'legacy-runtime',
          title: 'بازیابی‌شده',
          followUps: [
            FollowUp(
              id: 'fu-runtime',
              dateTime: DateTime(2026, 9, 20, 10),
              note: 'پیگیری بازیابی',
              completed: true,
            ),
          ],
        ).toJson(),
      ],
    };

    await tester.tap(find.byKey(const Key('restore_plain_backup_button')));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('تأیید بازیابی'), findsOneWidget);

    await tester.tap(find.byKey(const Key('restore_confirm_apply')));
    await tester.pump(const Duration(seconds: 1));

    final restored = await TaskStore().load();
    expect(restored.single.id, 'legacy-runtime');
    expect(restored.single.title, 'بازیابی‌شده');
    expect(restored.single.followUps.single.id, 'fu-runtime');
    expect(restored.single.followUps.single.note, 'پیگیری بازیابی');

    await store.save(const <Task>[]);
  });

  test('portable backup file round-trips Task and Calendar link metadata', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ArvinBackupManager.directoryKey: 'file-backed-runtime-smoke',
    });
    final tempDirectory = await Directory.systemTemp.createTemp(
      'arvin-backup-link-roundtrip-',
    );
    try {
      final file = File(
        '${tempDirectory.path}/arvin-calendar-link-backup.json',
      );
      final link = ExternalCalendarEventLink(
        reminderId: 'task-due:file-task',
        calendarId: 'calendar-file',
        eventId: 'event-file',
        lastSyncedFingerprint: 'fingerprint-file',
      );
      final linkStore = ExternalCalendarLinkStore();
      await linkStore.save([link]);
      final task = Task(
        id: 'file-task',
        title: 'کار در پشتیبان واقعی',
        checklist: const <String>['مرحله ذخیره‌شده'],
      );
      final manager = ArvinBackupManager(
        service: _FileBackedBackupService(file),
      );

      final backupName = await manager.backupCanonicalTasks(
        [task],
        calendarLinks: [link],
      );
      expect(backupName, file.uri.pathSegments.last);
      expect(await file.exists(), isTrue);
      expect(await file.length(), greaterThan(0));

      // Simulate a fresh installation's empty local link store, then read the
      // actual file bytes through the existing backup document decoder.
      await linkStore.save(const <ExternalCalendarEventLink>[]);
      final candidate = await manager.restoreCanonicalBackup();
      expect(candidate, isNotNull);
      expect(candidate!.tasks.single.id, 'file-task');
      expect(candidate.tasks.single.checklist, <String>['مرحله ذخیره‌شده']);
      expect(candidate.calendarLinks, hasLength(1));
      expect(candidate.calendarLinks!.single.eventId, 'event-file');
      expect(await linkStore.load(), isEmpty);

      await linkStore.restoreForTasks(
        restoredTaskIds: candidate.tasks.map((item) => item.id),
        backupLinks: candidate.calendarLinks!,
      );
      final restoredLinks = await linkStore.load();
      expect(restoredLinks, hasLength(1));
      expect(restoredLinks.single.calendarId, 'calendar-file');
      expect(restoredLinks.single.eventId, 'event-file');
    } finally {
      await tempDirectory.delete(recursive: true);
    }
  });
}
