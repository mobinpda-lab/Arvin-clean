import 'dart:convert';
import 'dart:typed_data';

import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_service.dart';
import 'package:arvin/models/person_reference.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/calendar_sync_plan_service.dart';
import 'package:arvin/services/external_calendar_link_store.dart';
import 'package:arvin/services/follow_up_reminder_delivery_service.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('deleted migrated legacy reminder does not return after SQL and backup restore',
      () async {
    final executor = NativeDatabase.memory();
    addTearDown(executor.close);
    final store = TaskStore(executor: executor);
    final legacyDate = DateTime(2026, 10, 10, 8, 30);
    final task = Task.fromJson(<String, dynamic>{
      'id': 'deleted-legacy-reminder',
      'title': 'یادآور حذف‌شده',
      'reminderDate': legacyDate.toIso8601String(),
    });

    expect(task.legacyTaskReminderMigrationVersion, 1);
    expect(task.taskReminders.map((reminder) => reminder.id),
        <String>['legacy-task-reminder']);

    // Deletion is represented by an empty canonical collection plus the
    // persisted migration tombstone; the old compatibility field stays intact.
    task.taskReminders.clear();
    await store.save(<Task>[task]);
    final afterSql = await store.load();
    expect(afterSql.single.legacyTaskReminderMigrationVersion, 1);
    expect(afterSql.single.reminderDate, legacyDate);
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
    final oldTask = Task.fromJson(<String, dynamic>{
      'id': 'task-reminder-integration',
      'title': 'پیگیری قرارداد',
      'reminderDate': legacyDate.toIso8601String(),
      'people': <Map<String, dynamic>>[
        PersonReference(id: 'person-7', displayName: 'مخاطب آزمایشی').toJson(),
      ],
    });

    expect(oldTask.taskReminders, hasLength(1));
    expect(oldTask.taskReminders.single.id, 'legacy-task-reminder');
    expect(oldTask.taskReminders.single.isLegacyTaskReminder, isTrue);

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
      reminderId: 'task-reminder-item:task-reminder-integration:legacy-task-reminder',
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
      'legacy-task-reminder',
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
      'legacy-task-reminder',
      'task-reminder-integration:reminder:2',
      'task-reminder-integration:reminder:3',
    });
    expect(task.legacyTaskReminderMigrationVersion, 1);
    expect(task.taskReminders.singleWhere((r) => r.isLegacyTaskReminder).date,
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

  test('Follow-up Reminder IDs and relation survive SQL plus canonical Backup/Restore',
      () async {
    final executor = NativeDatabase.memory();
    addTearDown(executor.close);
    final store = TaskStore(executor: executor);
    final reminderAt = DateTime(2026, 10, 22, 14, 30);
    final task = Task(
      id: 'task-follow-up-backup',
      title: 'قرارداد آزمایشی',
      people: <PersonReference>[
        PersonReference(id: 'person-follow-up-backup', displayName: 'مخاطب آزمایشی'),
      ],
      followUps: <FollowUp>[
        FollowUp(
          id: 'follow-up-backup',
          dateTime: DateTime(2026, 10, 20, 10),
          title: 'تماس نهایی',
          note: 'یادداشت حفظ شود',
          result: 'منتظر پاسخ',
          reminderDate: reminderAt,
          nextFollowUp: DateTime(2026, 10, 24, 10),
          waitingForResponse: true,
          personIds: <String>['person-follow-up-backup'],
        ),
      ],
      taskReminders: <TaskReminder>[
        TaskReminder(
          id: 'follow-up-reminder-follow-up-backup',
          title: 'تماس نهایی',
          date: reminderAt,
          sequence: 1,
          followUpId: 'follow-up-backup',
        ),
        TaskReminder(
          id: 'unrelated-backup-reminder',
          title: 'یادآور مستقل',
          date: DateTime(2026, 10, 23, 9),
          sequence: 2,
        ),
      ],
      nextReminderSequence: 3,
    );

    await store.save(<Task>[task]);
    final sqlReloaded = await TaskStore(executor: executor).load();
    final sqlTask = sqlReloaded.single;
    expect(sqlTask.taskReminders.singleWhere((item) => item.followUpId != null).id,
        'follow-up-reminder-follow-up-backup');

    final payload = <String, dynamic>{
      'tasks': sqlReloaded.map((value) => value.toJson()).toList(growable: false),
      'calendarLinks': <Map<String, dynamic>>[],
    };
    final bytes = ArvinBackupService.encodeBackupDocument(payload);
    final decoded = ArvinBackupService.validateBackupDocument(
      jsonDecode(utf8.decode(Uint8List.fromList(bytes))),
    );
    final restoredTasks = (decoded['tasks'] as List)
        .map((value) => Task.fromJson(Map<String, dynamic>.from(value as Map)))
        .toList(growable: false);

    await store.save(restoredTasks);
    final restored = (await TaskStore(executor: executor).load()).single;
    final linked = restored.taskReminders.singleWhere(
      (item) => item.followUpId == 'follow-up-backup',
    );
    expect(restored.id, 'task-follow-up-backup');
    expect(restored.followUps.single.id, 'follow-up-backup');
    expect(linked.id, 'follow-up-reminder-follow-up-backup');
    expect(linked.date, reminderAt);
    expect(linked.title, 'تماس نهایی');
    expect(restored.followUps.single.waitingForResponse, isTrue);
    expect(restored.followUps.single.personIds, <String>['person-follow-up-backup']);
    expect(restored.taskReminders.any((item) => item.id == 'unrelated-backup-reminder'),
        isTrue);
  });

}
