import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/follow_up_repository.dart';
import 'package:arvin/models/person_reference.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/g1_drift_schema.dart';
import 'package:arvin/services/task_store.dart';

final DateTime _actionAt = DateTime.utc(2026, 8, 15, 10, 15, 42, 123);
final DateTime _reminderAt = DateTime.utc(2026, 8, 16, 9, 0);
final DateTime _nextFollowUpAt = DateTime.utc(2026, 8, 20, 10, 15);
final DateTime _siblingActionAt = DateTime.utc(2026, 8, 10, 8, 30);
final DateTime _taskDueAt = DateTime.utc(2026, 9, 2, 14, 45);
final DateTime _legacyReminderAt = DateTime.utc(2026, 8, 18, 11, 20);
final DateTime _firstTaskReminderAt = DateTime.utc(2026, 8, 17, 12, 5);
final DateTime _secondTaskReminderAt = DateTime.utc(2026, 8, 19, 16, 40);

void main() {
  test(
    'completion true -> false -> true survives closing and reopening the same SQLite file',
    () async {
      final directory =
          await Directory.systemTemp.createTemp('arvin-follow-up-file-persistence-');
      final databasePath = '${directory.path}/arvin.sqlite';
      _Harness? active;

      try {
        // Seed through the canonical production Store, then close the first
        // connection so every transition starts from a fresh SQLite handle.
        active = await _openHarness(databasePath);
        await active.store.save(<Task>[
          Task(
            id: 'task-persistence-1',
            title: 'قرارداد فروش',
            description: 'شرح مستقل Task باید حفظ شود',
            createdAt: DateTime.utc(2026, 8, 1, 7),
            updatedAt: DateTime.utc(2026, 8, 14, 18),
            dueDate: _taskDueAt,
            reminderDate: _legacyReminderAt,
            followUpEnabled: true,
            category: 'فروش',
            tags: const <String>['قرارداد', 'مهم'],
            people: <PersonReference>[
              PersonReference(id: 'task-person-1', displayName: 'شخص مرتبط با Task'),
            ],
            taskReminders: <TaskReminder>[
              TaskReminder(
                id: 'task-reminder-1',
                title: 'یادآور مستقل اول',
                date: _firstTaskReminderAt,
                sequence: 1,
              ),
              TaskReminder(
                id: 'task-reminder-2',
                title: 'یادآور مستقل دوم',
                date: _secondTaskReminderAt,
                sequence: 2,
              ),
            ],
            nextReminderSequence: 3,
            followUps: <FollowUp>[
              FollowUp(
                id: 'follow-up-target',
                dateTime: _actionAt,
                title: 'پیگیری قرارداد',
                note: 'شرح کامل اقدام ثبت‌شده',
                result: 'پاسخ دریافت شد',
                reminderDate: _reminderAt,
                nextFollowUp: _nextFollowUpAt,
                completed: false,
                waitingForResponse: true,
                personIds: const <String>['person-1', 'person-2'],
              ),
              FollowUp(
                id: 'follow-up-sibling',
                dateTime: _siblingActionAt,
                title: 'سابقه مستقل دیگر',
                note: 'این سابقه نباید تغییر کند',
                result: 'در انتظار بررسی',
                completed: true,
                waitingForResponse: false,
                personIds: const <String>['person-3'],
              ),
            ],
          ),
        ]);
        await active.close();
        active = null;

        for (final completed in <bool>[true, false, true]) {
          active = await _openHarness(databasePath);
          final updated = await active.repository.setCompleted(
            'task-persistence-1',
            'follow-up-target',
            completed,
          );
          _expectTargetFollowUp(updated, completed: completed);

          // A successful mutation is not sufficient: destroy this connection
          // before reading from a newly-created executor, Store and Repository.
          await active.close();
          active = null;

          active = await _openHarness(databasePath);
          final tasks = await active.store.load();
          expect(tasks, hasLength(1));

          final task = tasks.single;
          expect(task.id, 'task-persistence-1');
          expect(task.title, 'قرارداد فروش');
          expect(task.description, 'شرح مستقل Task باید حفظ شود');
          expect(task.dueDate?.toIso8601String(), _taskDueAt.toIso8601String());
          expect(task.reminderDate?.toIso8601String(), _legacyReminderAt.toIso8601String());
          expect(task.followUpEnabled, isTrue);
          expect(task.category, 'فروش');
          expect(task.tags, <String>['قرارداد', 'مهم']);
          expect(task.people.map((person) => person.id).toList(), <String>['task-person-1']);

          // Independent Task reminders must retain their own IDs, dates and
          // sequence values, without being duplicated by a Follow-up mutation.
          expect(task.taskReminders, hasLength(2));
          expect(
            task.taskReminders.map((reminder) => reminder.id).toSet(),
            <String>{'task-reminder-1', 'task-reminder-2'},
          );
          expect(
            task.taskReminders.map((reminder) => reminder.id).toList(),
            hasLength(task.taskReminders.map((reminder) => reminder.id).toSet().length),
          );
          final firstReminder = task.taskReminders.singleWhere(
            (reminder) => reminder.id == 'task-reminder-1',
          );
          expect(firstReminder.title, 'یادآور مستقل اول');
          expect(firstReminder.date.toIso8601String(), _firstTaskReminderAt.toIso8601String());
          expect(firstReminder.sequence, 1);
          final secondReminder = task.taskReminders.singleWhere(
            (reminder) => reminder.id == 'task-reminder-2',
          );
          expect(secondReminder.title, 'یادآور مستقل دوم');
          expect(secondReminder.date.toIso8601String(), _secondTaskReminderAt.toIso8601String());
          expect(secondReminder.sequence, 2);
          expect(task.nextReminderSequence, 3);

          // Re-read the Follow-ups through the public Repository boundary.
          final followUps = await active.repository.loadForTask('task-persistence-1');
          expect(followUps, hasLength(2));
          expect(
            followUps.map((followUp) => followUp.id).toList(),
            <String>['follow-up-target', 'follow-up-sibling'],
          );
          final persistedTarget = followUps.singleWhere(
            (followUp) => followUp.id == 'follow-up-target',
          );
          _expectTargetFollowUp(persistedTarget, completed: completed);

          final sibling = followUps.singleWhere(
            (followUp) => followUp.id == 'follow-up-sibling',
          );
          expect(sibling.dateTime.toIso8601String(), _siblingActionAt.toIso8601String());
          expect(sibling.title, 'سابقه مستقل دیگر');
          expect(sibling.note, 'این سابقه نباید تغییر کند');
          expect(sibling.result, 'در انتظار بررسی');
          expect(sibling.completed, isTrue);
          expect(sibling.waitingForResponse, isFalse);
          expect(sibling.personIds, <String>['person-3']);

          // Assert canonical SQL rows and relation cardinality as well as the
          // model view, so accidental duplicate writes cannot hide in decoding.
          expect(await _count(active.executor, 'tasks'), 1);
          expect(await _count(active.executor, 'follow_ups'), 2);
          expect(await _count(active.executor, 'follow_up_people'), 3);
          expect(await _count(active.executor, 'task_people'), 1);

          await active.close();
          active = null;
        }
      } finally {
        if (active != null) {
          await active.close();
        }
        await directory.delete(recursive: true);
      }
    },
  );
}

Future<_Harness> _openHarness(String databasePath) async {
  final executor = NativeDatabase(File(databasePath));
  await G1DriftSchema.install(executor);
  // Mark the empty test database as already migrated so the production Store
  // uses only this file and never imports unrelated SharedPreferences state.
  await G1DriftSchema.markLegacyMigrationComplete(executor);
  final store = TaskStore(executor: executor);
  return _Harness(
    executor: executor,
    store: store,
    repository: FollowUpRepository(store: store),
  );
}

Future<int> _count(QueryExecutor executor, String table) async {
  const allowedTables = <String>{
    'tasks',
    'follow_ups',
    'follow_up_people',
    'task_people',
  };
  if (!allowedTables.contains(table)) {
    throw ArgumentError.value(table, 'table', 'Unsupported test table');
  }
  final rows = await executor.runSelect('SELECT COUNT(*) AS row_count FROM $table', const []);
  return (rows.single['row_count'] as num).toInt();
}

void _expectTargetFollowUp(FollowUp followUp, {required bool completed}) {
  expect(followUp.id, 'follow-up-target');
  // dateTime is the recorded action time. Completing the Follow-up must not
  // replace it with the time when the completion control was clicked.
  expect(followUp.dateTime.toIso8601String(), _actionAt.toIso8601String());
  expect(followUp.dateTime.isUtc, isTrue);
  expect(followUp.title, 'پیگیری قرارداد');
  expect(followUp.note, 'شرح کامل اقدام ثبت‌شده');
  expect(followUp.result, 'پاسخ دریافت شد');
  expect(followUp.reminderDate?.toIso8601String(), _reminderAt.toIso8601String());
  expect(followUp.nextFollowUp?.toIso8601String(), _nextFollowUpAt.toIso8601String());
  expect(followUp.completed, completed);
  expect(followUp.waitingForResponse, isTrue);
  expect(followUp.personIds, <String>['person-1', 'person-2']);
}

class _Harness {
  const _Harness({
    required this.executor,
    required this.store,
    required this.repository,
  });

  final QueryExecutor executor;
  final TaskStore store;
  final FollowUpRepository repository;

  Future<void> close() => executor.close();
}
