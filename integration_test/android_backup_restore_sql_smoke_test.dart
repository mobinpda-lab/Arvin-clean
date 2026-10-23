import 'dart:convert';
import 'dart:io';

import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_page.dart';
import 'package:arvin/backup_service.dart';
import 'package:arvin/backup_schedule.dart';
import 'package:arvin/services/app_settings_service.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/models/person_reference.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/calendar_sync_plan_service.dart';
import 'package:arvin/services/external_calendar_link_store.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter/material.dart';
import 'package:drift/native.dart';
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
  String createBackupFileName(DateTime dateTime) =>
      file.uri.pathSegments.last;

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
    var failAfterTaskWrite = false;
    var failAfterCalendarLinkWrite = false;
    var failAfterSettingsWrite = false;

    await tester.pumpWidget(
      MaterialApp(
        home: BackupPage(
          manager: manager,
          restoreStageHook: (stage) async {
            if (failAfterCalendarLinkWrite && stage == 'calendar-links') {
              failAfterCalendarLinkWrite = false;
              throw StateError('injected failure after Calendar-link write');
            }
            if (failAfterSettingsWrite && stage == 'settings') {
              failAfterSettingsWrite = false;
              throw StateError('injected failure after settings write');
            }
          },
          loadTasks: () async =>
              (await freshStore.load()).map((task) => task.toJson()).toList(),
          replaceTasks: (rawTasks) async {
            await store.save(
              rawTasks.map((raw) => Task.fromJson(raw)).toList(growable: false),
            );
            if (failAfterTaskWrite) {
              failAfterTaskWrite = false;
              throw StateError('injected failure after TaskStore write');
            }
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('create_backup_button')));
    await tester.pumpAndSettle();
    expect(service.writes, 1);
    expect(service.document?['tasks'], isNotEmpty);
    expect(service.document?['categories'], contains('فروش'));
    expect(service.document?['tags'], contains('مهم'));

    service.document = <String, dynamic>{
      'type': ArvinBackupService.backupType,
      'formatVersion': ArvinBackupService.backupFormatVersion,
      'categories': <String>['دسته پشتیبان مستقل'],
      'tags': <String>['برچسب مستقل'],
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
    expect(await TaskStore().loadCategories(), contains('دسته پشتیبان مستقل'));
    expect(await TaskStore().loadTags(), contains('برچسب مستقل'));

    // The preceding successful restore shows a SnackBar. Clear it before the
    // independent failure scenario so its message cannot queue behind success.
    ScaffoldMessenger.of(tester.element(find.byType(BackupPage))).clearSnackBars();
    await tester.pump();

    // Exercise the actual BackupPage restore orchestration, not only the
    // rollback helper: fail immediately after the candidate Task write and
    // prove that the pre-restore task state is restored before the UI reports
    // failure. Later Project/link/settings-stage injection remains separate.
    await store.save([
      Task(id: 'old-runtime', title: 'اطلاعات قبلی'),
    ]);
    service.document = <String, dynamic>{
      'type': ArvinBackupService.backupType,
      'formatVersion': ArvinBackupService.backupFormatVersion,
      'categories': <String>['دسته پشتیبان مستقل'],
      'tags': <String>['برچسب مستقل'],
      'tasks': <Map<String, dynamic>>[
        Task(id: 'candidate-runtime', title: 'اطلاعات جایگزین').toJson(),
      ],
    };
    failAfterTaskWrite = true;
    await tester.tap(find.byKey(const Key('restore_plain_backup_button')));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('تأیید بازیابی'), findsOneWidget);
    await tester.tap(find.byKey(const Key('restore_confirm_apply')));
    await tester.pump(const Duration(seconds: 1));

    final rolledBack = await TaskStore().load();
    expect(rolledBack, hasLength(1));
    expect(rolledBack.single.id, 'old-runtime');
    expect(rolledBack.single.title, 'اطلاعات قبلی');
    expect(
      find.text('بازیابی کامل نشد؛ اطلاعات قبلی به حالت پیشین بازگردانده شد.'),
      findsOneWidget,
    );

    ScaffoldMessenger.of(tester.element(find.byType(BackupPage))).clearSnackBars();
    await tester.pump();

    // Exercise a later real mutation boundary: Task and Project writes plus
    // Calendar-link restoration must all roll back if that stage fails.
    await store.save([Task(id: 'old-late-runtime', title: 'کار قبلی مرحله دیرهنگام')]);
    final localProject = ProjectPlan(
      id: 'old-project-runtime',
      title: 'پروژه قبلی',
      itemIds: const <String>[],
    );
    await ProjectStore().save([localProject]);
    final localCalendarLink = ExternalCalendarEventLink(
      reminderId: 'task-due:old-late-runtime',
      calendarId: 'old-calendar',
      eventId: 'old-event',
      lastSyncedFingerprint: 'old-fingerprint',
    );
    await ExternalCalendarLinkStore().save([localCalendarLink]);

    service.document = <String, dynamic>{
      'type': ArvinBackupService.backupType,
      'formatVersion': ArvinBackupService.backupFormatVersion,
      'projects': manager.projectCodec.encodeList([
        ProjectPlan(
          id: 'candidate-project-runtime',
          title: 'پروژه جایگزین',
          itemIds: const <String>[],
        ),
      ]),
      'calendarLinks': <Map<String, dynamic>>[
        <String, dynamic>{
          'reminderId': 'task-due:candidate-runtime',
          'calendarId': 'candidate-calendar',
          'eventId': 'candidate-event',
          'lastSyncedFingerprint': 'candidate-fingerprint',
        },
      ],
      'tasks': <Map<String, dynamic>>[
        Task(id: 'candidate-runtime', title: 'کار جایگزین').toJson(),
      ],
    };
    failAfterCalendarLinkWrite = true;
    await tester.tap(find.byKey(const Key('restore_plain_backup_button')));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('تأیید بازیابی'), findsOneWidget);
    await tester.tap(find.byKey(const Key('restore_confirm_apply')));
    await tester.pump(const Duration(seconds: 1));

    final lateRolledBackTasks = await TaskStore().load();
    expect(lateRolledBackTasks, hasLength(1));
    expect(lateRolledBackTasks.single.id, 'old-late-runtime');
    expect(
      (await ProjectStore().load()).map((project) => project.id),
      ['old-project-runtime'],
    );
    final lateRolledBackLinks = await ExternalCalendarLinkStore().load();
    expect(lateRolledBackLinks, hasLength(1));
    expect(lateRolledBackLinks.single.toJson(), localCalendarLink.toJson());
    expect(
      find.text('بازیابی کامل نشد؛ اطلاعات قبلی به حالت پیشین بازگردانده شد.'),
      findsOneWidget,
    );

    // Inject a failure after settings and backup-schedule mutations have
    // actually occurred. This closes the final late-stage boundary for the
    // BackupPage entry point and verifies all previously written stores roll
    // back together, including settings and schedule.
    ScaffoldMessenger.of(tester.element(find.byType(BackupPage))).clearSnackBars();
    await tester.pump();
    final settingsBeforeFinalFailure = await AppSettingsService().load();
    final scheduleBeforeFinalFailure = await BackupSchedule.load();
    service.document = <String, dynamic>{
      'type': ArvinBackupService.backupType,
      'formatVersion': ArvinBackupService.backupFormatVersion,
      'projects': manager.projectCodec.encodeList([
        ProjectPlan(
          id: 'settings-candidate-project',
          title: 'پروژه تنظیمات جایگزین',
          itemIds: const <String>[],
        ),
      ]),
      'calendarLinks': <Map<String, dynamic>>[
        <String, dynamic>{
          'reminderId': 'task-due:settings-candidate-task',
          'calendarId': 'settings-candidate-calendar',
          'eventId': 'settings-candidate-event',
          'lastSyncedFingerprint': 'settings-candidate-fingerprint',
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
      'tasks': <Map<String, dynamic>>[
        Task(id: 'settings-candidate-task', title: 'کار جایگزین تنظیمات').toJson(),
      ],
    };
    failAfterSettingsWrite = true;
    await tester.tap(find.byKey(const Key('restore_plain_backup_button')));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('تأیید بازیابی'), findsOneWidget);
    await tester.tap(find.byKey(const Key('restore_confirm_apply')));
    await tester.pump(const Duration(seconds: 1));

    expect((await TaskStore().load()).map((task) => task.id), ['old-late-runtime']);
    expect(
      (await ProjectStore().load()).map((project) => project.id),
      ['old-project-runtime'],
    );
    final settingsRolledBackLinks = await ExternalCalendarLinkStore().load();
    expect(settingsRolledBackLinks, hasLength(1));
    expect(settingsRolledBackLinks.single.toJson(), localCalendarLink.toJson());
    expect(
      (await AppSettingsService().load()).fontSize,
      settingsBeforeFinalFailure.fontSize,
    );
    final scheduleAfterFinalFailure = await BackupSchedule.load();
    expect(scheduleAfterFinalFailure.enabled, scheduleBeforeFinalFailure.enabled);
    expect(scheduleAfterFinalFailure.hour, scheduleBeforeFinalFailure.hour);
    expect(scheduleAfterFinalFailure.minute, scheduleBeforeFinalFailure.minute);
    expect(
      scheduleAfterFinalFailure.frequency,
      scheduleBeforeFinalFailure.frequency,
    );
    expect(
      find.text('بازیابی کامل نشد؛ اطلاعات قبلی به حالت پیشین بازگردانده شد.'),
      findsOneWidget,
    );

    await store.save(const <Task>[]);
  });

  test(
    'encrypted portable file round-trips synthetic Task, People and Calendar metadata',
    () async {
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
        final person = PersonReference(
          id: 'person-file-synthetic',
          displayName: 'شخص آزمایشی انتقال',
        );
        final task = Task(
          id: 'file-task',
          title: 'کار در پشتیبان واقعی',
          category: 'دسته انتقال مصنوعی',
          tags: const <String>['برچسب انتقال مصنوعی'],
          checklist: const <String>['مرحله ذخیره‌شده'],
          followUps: <FollowUp>[
            FollowUp(
              id: 'file-follow-up',
              dateTime: DateTime(2026, 10, 23, 9),
              note: 'پیگیری مصنوعی',
              personIds: <String>[person.id],
            ),
          ],
        );
        final manager = ArvinBackupManager(
          service: _FileBackedBackupService(file),
        );

        final backupName = await manager.backupCanonicalTasks(
          [task],
          settings: <String, dynamic>{'themeMode': 'dark', 'usePersianDate': true},
          projects: <ProjectPlan>[
            ProjectPlan(
              id: 'project-file-synthetic',
              title: 'پروژه انتقال آزمایشی',
              isArchived: true,
              itemIds: <String>['file-task'],
            ),
          ],
          calendarLinks: [link],
          categories: const <String>['دسته انتقال مصنوعی'],
          tags: const <String>['برچسب انتقال مصنوعی'],
          people: [person],
          encryptionPassphrase: 'synthetic-transfer-passphrase',
        );
        expect(backupName, file.uri.pathSegments.last);
        expect(await file.exists(), isTrue);
        expect(await file.length(), greaterThan(0));
        final encryptedBytes = await file.readAsBytes();
        expect(utf8.decode(encryptedBytes), isNot(contains('کار در پشتیبان واقعی')));

        // Simulate a fresh installation's empty local link store, then read
        // the actual encrypted file bytes through the existing backup decoder.
        await linkStore.save(const <ExternalCalendarEventLink>[]);
        final candidate = await manager.restoreCanonicalBackup(
          passphrase: 'synthetic-transfer-passphrase',
        );
        expect(candidate, isNotNull);
        expect(candidate!.tasks.single.id, 'file-task');
        expect(
          candidate.tasks.single.checklist,
          <String>['مرحله ذخیره‌شده'],
        );
        expect(candidate.tasks.single.followUps.single.id, 'file-follow-up');
        expect(candidate.tasks.single.followUps.single.personIds, <String>[person.id]);
        expect(candidate.people, hasLength(1));
        expect(candidate.people!.single.id, person.id);
        expect(candidate.people!.single.displayName, person.displayName);
        expect(candidate.calendarLinks, hasLength(1));
        expect(candidate.calendarLinks!.single.eventId, 'event-file');
        expect(await linkStore.load(), isEmpty);

        // Apply the validated candidate to an independent clean SQLite database,
        // simulating the data side of a fresh Android installation on this emulator.
        final destinationExecutor = NativeDatabase.memory();
        try {
          final destinationStore = TaskStore(executor: destinationExecutor);
          await destinationStore.save(candidate.tasks);
          await destinationStore.savePeopleDirectory(candidate.people!);
          await destinationStore.mergeCatalogs(
            categories: candidate.categories ?? const <String>[],
            tags: candidate.tags ?? const <String>[],
          );
          final destinationProjects = ProjectStore(executor: destinationExecutor);
          await destinationProjects.save(candidate.projects);

          final reopenedTasks = await TaskStore(executor: destinationExecutor).load();
          expect(reopenedTasks, hasLength(1));
          expect(reopenedTasks.single.id, 'file-task');
          expect(reopenedTasks.single.checklist, <String>['مرحله ذخیره‌شده']);
          expect(reopenedTasks.single.followUps.single.personIds, <String>[person.id]);
          expect((await destinationStore.loadPeopleDirectory()).single.id, person.id);
          expect(await destinationStore.loadCategories(), contains('دسته انتقال مصنوعی'));
          expect(await destinationStore.loadTags(), contains('برچسب انتقال مصنوعی'));
          final reopenedProjects = await destinationProjects.load();
          expect(reopenedProjects, hasLength(1));
          expect(reopenedProjects.single.id, 'project-file-synthetic');
          expect(reopenedProjects.single.isArchived, isTrue);
          expect(reopenedProjects.single.itemIds, contains('file-task'));
          expect(candidate.settings?['themeMode'], 'dark');
        } finally {
          await destinationExecutor.close();
        }

        await expectLater(
          manager.restoreCanonicalBackup(passphrase: 'wrong-synthetic-passphrase'),
          throwsA(isA<FormatException>()),
        );
        await file.writeAsBytes(
          encryptedBytes.sublist(0, encryptedBytes.length ~/ 2),
          flush: true,
        );
        await expectLater(
          manager.restoreCanonicalBackup(passphrase: 'synthetic-transfer-passphrase'),
          throwsA(isA<FormatException>()),
        );
        await file.writeAsBytes(encryptedBytes, flush: true);

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
    },
  );
}