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
}
