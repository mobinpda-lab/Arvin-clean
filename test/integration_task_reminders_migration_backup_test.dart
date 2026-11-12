import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_service.dart';
import 'package:arvin/models/person_reference.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/calendar_sync_plan_service.dart';
import 'package:arvin/services/external_calendar_link_store.dart';
import 'package:arvin/services/follow_up_reminder_delivery_service.dart';
import 'package:arvin/services/follow_up_reminder_projection.dart';
import 'package:arvin/services/follow_up_reminder_alarm_planner.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('disabled reminders stay disabled after database close and application restart', () async {
    final directory = await Directory.systemTemp.createTemp('arvin-disabled-reminder-reopen-');
    final databaseFile = File('${directory.path}/arvin.sqlite');
    var executor = NativeDatabase(databaseFile);
    final now = DateTime(2026, 11, 8, 10);
    final original = Task(
      id: 'disabled-after-restart',
      title: 'یادآورهای خاموش',
      taskReminders: [
        TaskReminder(id: 'future-off', title: 'آینده خاموش', date: now.add(const Duration(hours: 1)), sequence: 1, isEnabled: false),
        TaskReminder(id: 'past-off', title: 'گذشته خاموش', date: now.subtract(const Duration(hours: 1)), sequence: 2, isEnabled: false),
      ],
    );
    await TaskStore(executor: executor).save([original]);
    await executor.close();

    executor = NativeDatabase(databaseFile);
    try {
      final restored = (await TaskStore(executor: executor).load()).single;
      expect(restored.taskReminders.map((item) => item.isEnabled), [false, false]);
      expect(const FollowUpReminderProjection().pending([restored], now: now), isEmpty);
      expect(const FollowUpReminderDeliveryService().due([restored], now: now), isEmpty);
      expect(
        const FollowUpReminderAlarmPlanner().nextAlarmAt(
          [restored], deliveredState: const <String, String>{}, now: now,
        ),
        isNull,
      );
    } finally {
      await executor.close();
      await directory.delete(recursive: true);
    }
  });

  test('deleted migrated legacy reminder does not return after SQL and backup restore',
      () async {
    final executor = NativeDatabase.memory();
    addTearDown(executor.close);
    final store = TaskStore(executor: executor);
    final legacyDate = DateTime(2026, 10, 10, 8, 30);
    final task = Task.fromLegacyJson(<String, dynamic>{
      'id': 'deleted-legacy-reminder',
      'title': 'یادآور حذف‌شده',
      'reminderDate': legacyDate.toIso8601String(),
    });

    expect(task.legacyTaskReminderMigrationVersion, 1);
    expect(task.taskReminders.map((reminder) => reminder.id),
        <String>['legacy-task-reminder-deleted-legacy-reminder']);

    // Deletion is represented by an empty canonical collection plus the
    // migration marker, which blocks stale legacy payload resurrection.
    task.taskReminders.clear();
    await store.save(<Task>[task]);
    final afterSql = await store.load();
    expect(afterSql.single.legacyTaskReminderMigrationVersion, 1);
    expect(afterSql.single.reminderDate, isNull,
        reason: 'the canonical reminder was deleted and the migration tombstone prevents legacy resurrection');
    expect(afterSql.single.taskReminders, isEmpty);

    final payload = <String, dynamic>{
      'tasks': afterSql.map((value) => value.toJson()).toList(growable: false),
      'calendarLinks': <Map<String, dynamic>>[],
    };
    final bytes = ArvinBackupService.encodeBackupDocument(payload);
    final decoded = ArvinBackupService.validateBackupDocument(
      jsonDecode(utf8.decode(Uint8List.fromList(bytes))),
    );
    final restoredTasks = (decoded['tasks'] as List)
        .map((value) => Task.fromJson(Map<String, dynamic>.from(value as Map)))
        .toList(growable: false);
    expect(restoredTasks.single.legacyTaskReminderMigrationVersion, 1);
    expect(restoredTasks.single.taskReminders, isEmpty);

    await store.save(restoredTasks);
    final afterRestore = await store.load();
    expect(afterRestore.single.taskReminders, isEmpty,
        reason: 'legacy compatibility data must not resurrect a deleted reminder');
    expect(afterRestore.single.legacyTaskReminderMigrationVersion, 1);
  });

  test('legacy Task reminder survives SQL and canonical backup/restore exactly once',
      () async {
    final executor = NativeDatabase.memory();
    addTearDown(executor.close);
    final store = TaskStore(executor: executor);
    final legacyDate = DateTime(2026, 10, 10, 8, 30);
    final oldTask = Task.fromLegacyJson(<String, dynamic>{
      'id': 'task-reminder-integration',
      'title': 'پیگیری قرارداد',
      'reminderDate': legacyDate.toIso8601String(),
      'people': <Map<String, dynamic>>[
        PersonReference(id: 'person-7', displayName: 'مخاطب آزمایشی').toJson(),
      ],
    });

    expect(oldTask.taskReminders, hasLength(1));
    expect(oldTask.taskReminders.single.id, 'legacy-task-reminder-task-reminder-integration');
    

    oldTask.taskReminders.addAll(<TaskReminder>[
      TaskReminder(
        id: 'task-reminder-integration:reminder:2',
        title: 'یادآور مستقل اول',
        date: DateTime(2026, 10, 12, 9),
        sequence: 2,
      ),
      TaskReminder(
        id: 'task-reminder-integration:reminder:3',
        title: 'یادآور مستقل دوم',
        date: DateTime(2026, 10, 12, 10),
        sequence: 3,
      ),
    ]);
    oldTask.nextReminderSequence = 4;

    final eventLink = ExternalCalendarEventLink(
      reminderId: 'task-reminder-item:task-reminder-integration:legacy-task-reminder-task-reminder-integration',
      calendarId: 'calendar-local-1',
      eventId: 'provider-event-stable-42',
      lastSyncedFingerprint: 'fingerprint-v1',
    );
    final linkStore = ExternalCalendarLinkStore();
    await linkStore.save(<ExternalCalendarEventLink>[eventLink]);

    // The old scheduler key was task:<taskId>; it must still suppress the
    // migrated legacy reminder after SQL reload and restore.
    const delivery = FollowUpReminderDeliveryService();
    final preMigrationIdentity = 'task:task-reminder-integration@'
        '${legacyDate.toIso8601String()}';

    await store.save(<Task>[oldTask]);
    final sqlReloaded = await TaskStore(executor: executor).load();
    expect(sqlReloaded, hasLength(1));
    expect(sqlReloaded.single.id, oldTask.id);
    expect(sqlReloaded.single.people.single.id, 'person-7');
    expect(sqlReloaded.single.taskReminders.map((r) => r.id).toSet(), {
      'legacy-task-reminder-task-reminder-integration',
      'task-reminder-integration:reminder:2',
      'task-reminder-integration:reminder:3',
    });

    final payload = <String, dynamic>{
      'tasks': sqlReloaded.map((task) => task.toJson()).toList(),
      'calendarLinks': (await linkStore.load()).map((link) => link.toJson()).toList(),
    };
    final bytes = ArvinBackupService.encodeBackupDocument(payload);
    final decoded = ArvinBackupService.validateBackupDocument(
      jsonDecode(utf8.decode(Uint8List.fromList(bytes))),
    );
    final backupTasks = (decoded['tasks'] as List)
        .map((value) => Task.fromJson(Map<String, dynamic>.from(value as Map)))
        .toList();
    final reconciled = ArvinBackupManager.reconcileTasksById(
      current: sqlReloaded,
      backup: backupTasks,
    );
    await store.save(reconciled);

    final restored = await TaskStore(executor: executor).load();
    expect(restored, hasLength(1), reason: 'restore must not duplicate Tasks');
    final task = restored.single;
    expect(task.id, 'task-reminder-integration');
    expect(task.people.map((person) => person.id), <String>['person-7']);
    expect(task.taskReminders, hasLength(3),
        reason: 'restore must not duplicate any Reminder');
    expect(task.taskReminders.map((r) => r.id).toSet(), {
      'legacy-task-reminder-task-reminder-integration',
      'task-reminder-integration:reminder:2',
      'task-reminder-integration:reminder:3',
    });
    expect(task.legacyTaskReminderMigrationVersion, 1);
    expect(task.taskReminders.singleWhere((r) => r.id == 'legacy-task-reminder-${task.id}').date,
        legacyDate);

    final restoredLinks = (decoded['calendarLinks'] as List)
        .map((value) => Map<String, dynamic>.from(value as Map))
        .map((value) => ExternalCalendarEventLink(
              reminderId: value['reminderId'] as String,
              calendarId: value['calendarId'] as String,
              eventId: value['eventId'] as String,
              lastSyncedFingerprint: value['lastSyncedFingerprint'] as String,
            ))
        .toList();
    await linkStore.restoreForTasks(
      restoredTaskIds: restored.map((value) => value.id),
      backupLinks: restoredLinks,
      currentLinks: const <ExternalCalendarEventLink>[],
    );
    final linksAfterRestore = await linkStore.load();
    expect(linksAfterRestore, hasLength(1));
    expect(linksAfterRestore.single.eventId, 'provider-event-stable-42');

    final dueAfterRestore = delivery.due(
      restored,
      now: DateTime(2026, 10, 11),
      deliveredIdentities: <String>{preMigrationIdentity},
    );
    expect(dueAfterRestore, isEmpty,
        reason: 'a previously delivered legacy alarm must not be reactivated');
  });

  test('canonical backup file restores multiple Reminders and Follow-up Person links into a new SQLite file',
      () async {
    final directory = await Directory.systemTemp.createTemp(
      'arvin-file-backup-restore-acceptance-',
    );
    final sourceFile = File('${directory.path}/source.sqlite');
    final restoredFile = File('${directory.path}/restored.sqlite');
    final backupFile = File('${directory.path}/Arvin_Backup_acceptance.json');
    NativeDatabase? sourceDatabase;
    NativeDatabase? restoredDatabase;
    final person = PersonReference(
      id: 'backup-restore-person-1',
      displayName: 'مخاطب بازیابی',
    );
    final sourceTask = Task(
      id: 'backup-restore-task-1',
      title: 'اعتبارسنجی بازیابی فایل',
      people: [person],
      taskReminders: [
        TaskReminder(
          id: 'backup-restore-reminder-1',
          title: 'یادآور خاموش',
          date: DateTime(2026, 11, 13, 9),
          sequence: 1,
          isEnabled: false,
        ),
        TaskReminder(
          id: 'backup-restore-reminder-2',
          title: 'یادآور فعال',
          date: DateTime(2026, 11, 14, 10),
          sequence: 2,
          isEnabled: true,
        ),
      ],
      followUps: [
        FollowUp(
          id: 'backup-restore-follow-up-1',
          completedAt: DateTime(2026, 11, 12, 11),
          title: 'تماس ثبت‌شده',
          note: 'سوابق باید بعد از Restore باقی بمانند',
          result: 'منتظر پاسخ',
          completed: true,
          waitingForResponse: true,
          personIds: const ['backup-restore-person-1'],
        ),
      ],
    );

    try {
      // Source: persist to a real SQLite file and close it before producing
      // the portable backup from the reloaded canonical records.
      sourceDatabase = NativeDatabase(sourceFile);
      await TaskStore(executor: sourceDatabase).save([sourceTask]);
      final sourceReloaded = await TaskStore(executor: sourceDatabase).load();
      expect(sourceReloaded, hasLength(1));
      expect(sourceReloaded.single.taskReminders, hasLength(2));
      expect(sourceReloaded.single.followUps.single.personIds,
          ['backup-restore-person-1']);

      final payload = <String, dynamic>{
        'tasks': sourceReloaded.map((task) => task.toJson()).toList(),
        'peopleDirectory': [person.toJson()],
      };
      final backupBytes = ArvinBackupService.encodeBackupDocument(payload);
      await backupFile.writeAsBytes(backupBytes, flush: true);
      await sourceDatabase.close();
      sourceDatabase = null;

      // Read and validate the actual backup file from disk, then restore into
      // a different file-backed database rather than the original executor.
      final bytesFromDisk = await backupFile.readAsBytes();
      final document = await ArvinBackupService().decodeBackupBytes(
        Uint8List.fromList(bytesFromDisk),
      );
      final restoredTasks = (document['tasks'] as List)
          .map((value) => Task.fromLegacyJson(
                Map<String, dynamic>.from(value as Map),
              ))
          .toList(growable: false);
      expect(restoredTasks, hasLength(1));

      restoredDatabase = NativeDatabase(restoredFile);
      await TaskStore(executor: restoredDatabase).save(restoredTasks);
      await restoredDatabase.close();
      restoredDatabase = null;

      // A second close/reopen verifies the restored database itself, not only
      // the in-memory objects produced by decoding the backup document.
      restoredDatabase = NativeDatabase(restoredFile);
      final afterRestore = await TaskStore(executor: restoredDatabase).load();
      expect(afterRestore, hasLength(1));
      final restored = afterRestore.single;
      expect(restored.id, 'backup-restore-task-1');
      expect(restored.taskReminders.map((item) => item.id), [
        'backup-restore-reminder-1',
        'backup-restore-reminder-2',
      ]);
      expect(restored.taskReminders.map((item) => item.sequence), [1, 2]);
      expect(restored.taskReminders.map((item) => item.isEnabled), [false, true]);
      expect(restored.followUps.map((item) => item.id),
          ['backup-restore-follow-up-1']);
      expect(restored.followUps.single.personIds,
          ['backup-restore-person-1']);
      expect(restored.followUps.single.waitingForResponse, isTrue);
      expect(restored.people.map((item) => item.id),
          ['backup-restore-person-1']);
      expect(
        await restoredDatabase.runSelect('PRAGMA foreign_key_check', const []),
        isEmpty,
      );
      final foreignKeys = await restoredDatabase.runSelect(
        'PRAGMA foreign_keys',
        const [],
      );
      expect(foreignKeys.single['foreign_keys'], 1);
    } finally {
      if (sourceDatabase != null) await sourceDatabase.close();
      if (restoredDatabase != null) await restoredDatabase.close();
      await directory.delete(recursive: true);
    }
  });

}
