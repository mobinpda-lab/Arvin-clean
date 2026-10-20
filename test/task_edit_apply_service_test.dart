import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_edit_apply_service.dart';
import 'package:arvin/services/task_recurrence_repository.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final appliedAt = DateTime(2026, 8, 28, 17);
  final service = TaskEditApplyService(now: () => appliedAt);

  test('applies due date and other editable fields to canonical Task', () {
    final originalFollowUps = [
      FollowUp(
        id: 'fu-1',
        dateTime: DateTime(2026, 8, 27, 10),
        note: 'سابقه',
      ),
    ];
    final target = Task(
      id: 'task-1',
      title: 'قدیمی',
      description: 'قبل',
      dueDate: DateTime(2026, 8, 29, 9),
      followUpEnabled: true,
      followUpDate: DateTime(2026, 8, 29, 10),
      tags: ['قدیمی'],
      category: 'فروش',
      checklist: ['یک'],
      reminderDate: DateTime(2026, 8, 29, 8),
      priority: TaskPriority.low,
      archived: true,
      completed: true,
      followUps: originalFollowUps,
      createdAt: DateTime(2026, 8, 20),
    );
    final edited = Task(
      id: 'task-1',
      title: 'جدید',
      description: 'بعد',
      dueDate: DateTime(2026, 8, 30, 14),
      allDay: true,
      followUpEnabled: false,
      tags: ['مهم', 'مشتری'],
      category: 'مشتریان',
      checklist: ['یک', 'دو'],
      reminderDate: DateTime(2026, 8, 30, 12),
      priority: TaskPriority.high,
      archived: false,
      completed: false,
      followUps: const [],
      createdAt: DateTime(2026, 8, 28),
    );

    service.apply(target, edited);

    expect(target.title, 'جدید');
    expect(target.description, 'بعد');
    expect(target.dueDate, DateTime(2026, 8, 30, 14));
    expect(target.allDay, isTrue);
    expect(target.followUpEnabled, isFalse);
    expect(target.followUpDate, isNull);
    expect(target.tags, ['مهم', 'مشتری']);
    expect(target.category, 'مشتریان');
    expect(target.checklist, ['یک', 'دو']);
    expect(target.reminderDate, DateTime(2026, 8, 30, 12));
    expect(target.taskReminders, isEmpty);
    expect(target.nextReminderSequence, 1);
    expect(target.priority, TaskPriority.high);
    expect(target.completed, isFalse);
    expect(target.updatedAt, appliedAt);
  });

  test('applies disabled checklist state while preserving checklist rows', () {
    final target = Task(
      id: 'checklist-apply',
      title: 'کار',
      checklist: const ['[ ] کیف', '[x] کتاب'],
    );
    final edited = Task(
      id: 'checklist-apply',
      title: 'کار',
      checklist: const ['[ ] کیف', '[x] کتاب'],
      checklistEnabled: false,
    );

    TaskEditApplyService(now: () => DateTime(2026, 10, 9)).apply(target, edited);

    expect(target.checklistEnabled, isFalse);
    expect(target.checklist, const ['[ ] کیف', '[x] کتاب']);
  });

  test('rebuilds current and future recurring checklist while preserving past snapshots and lifecycle', () {
    final effectiveAt = DateTime(2026, 10, 5, 12);
    final dates = List<DateTime>.generate(
      7,
      (index) => DateTime(2026, 10, index + 1, 6),
    );
    final originalChecklists = <String, List<String>>{
      dates[0].toIso8601String(): const ['[x] A', '[ ] B', '[x] C'],
      dates[1].toIso8601String(): const ['[ ] A', '[x] B', '[ ] C'],
      dates[2].toIso8601String(): const ['[x] A', '[x] B', '[ ] C'],
      dates[3].toIso8601String(): const ['[ ] A', '[ ] B', '[x] C'],
      dates[4].toIso8601String(): const ['[x] A', '[x] B', '[x] C'],
      dates[5].toIso8601String(): const ['[ ] A', '[x] B', '[ ] C'],
      dates[6].toIso8601String(): const ['[x] A', '[ ] B', '[ ] C'],
    };
    final originalHistory = <String, Map<String, dynamic>>{
      dates[4].toIso8601String(): {
        'scheduledDate': dates[4].toIso8601String(),
        'status': 'completed',
        'completionDate': DateTime(2026, 10, 5, 7).toIso8601String(),
      },
      dates[5].toIso8601String(): {
        'scheduledDate': dates[5].toIso8601String(),
        'status': 'cancelled',
        'result': 'owner cancelled',
      },
    };
    final target = Task(
      id: 'recurring-task',
      title: 'آماده‌سازی مدرسه',
      checklist: const ['[ ] A', '[ ] B', '[ ] C'],
      recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
      checklistOccurrences: {
        for (final entry in originalChecklists.entries)
          entry.key: List<String>.of(entry.value),
      },
      occurrenceHistory: {
        for (final entry in originalHistory.entries)
          entry.key: Map<String, dynamic>.from(entry.value),
      },
    );
    final edited = Task(
      id: 'editor-copy-id-is-not-canonical',
      title: 'آماده‌سازی مدرسه',
      checklist: const ['[ ] A', '[ ] B', '[ ] D'],
      recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
    );
    final service = TaskEditApplyService(now: () => effectiveAt);

    service.apply(target, edited);

    expect(target.id, 'recurring-task');
    expect(target.checklist, const ['[ ] A', '[ ] B', '[ ] D']);
    expect(target.checklistOccurrences.keys.toSet(), originalChecklists.keys.toSet());
    for (var index = 0; index < 4; index++) {
      expect(
        target.checklistOccurrences[dates[index].toIso8601String()],
        originalChecklists[dates[index].toIso8601String()],
        reason: 'Past occurrence ${dates[index]} must be immutable.',
      );
    }
    for (var index = 4; index < 7; index++) {
      expect(
        target.checklistOccurrences[dates[index].toIso8601String()],
        const ['[ ] A', '[ ] B', '[ ] D'],
        reason: 'Current/future occurrence ${dates[index]} must be rebuilt unchecked.',
      );
    }
    expect(target.occurrenceHistory, originalHistory);

    // Retrying the same template edit must not create keys or duplicate items.
    service.apply(target, edited);
    expect(target.checklistOccurrences.keys.toSet(), originalChecklists.keys.toSet());
    for (var index = 4; index < 7; index++) {
      expect(
        target.checklistOccurrences[dates[index].toIso8601String()],
        const ['[ ] A', '[ ] B', '[ ] D'],
      );
    }
    expect(target.occurrenceHistory, originalHistory);
  });

  test('canonical TaskStore persists checklist evolution with unchanged occurrence keys', () async {
    SharedPreferences.setMockInitialValues({});
    await TaskStore.resetTestDatabase();
    final store = TaskStore();
    final effectiveAt = DateTime(2026, 10, 5, 12);
    final dates = List<DateTime>.generate(
      7,
      (index) => DateTime(2026, 10, index + 1, 6),
    );
    final target = Task(
      id: 'storage-checklist-evolution',
      title: 'Storage checklist evolution',
      checklist: const ['[ ] A', '[ ] B', '[ ] C'],
      recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
      checklistOccurrences: {
        for (var index = 0; index < dates.length; index++)
          dates[index].toIso8601String(): index < 4
              ? const ['[x] A', '[ ] B', '[x] C']
              : const ['[x] A', '[x] B', '[x] C'],
      },
      occurrenceHistory: {
        dates[4].toIso8601String(): {
          'scheduledDate': dates[4].toIso8601String(),
          'status': 'completed',
        },
        dates[5].toIso8601String(): {
          'scheduledDate': dates[5].toIso8601String(),
          'status': 'cancelled',
        },
      },
    );
    await store.save([target]);
    final edited = Task(
      id: target.id,
      title: target.title,
      checklist: const ['[ ] A', '[ ] B', '[ ] D'],
      recurrence: target.recurrence,
    );

    await store.mutate<void>((tasks) {
      TaskEditApplyService(now: () => effectiveAt).apply(tasks.single, edited);
    });

    final reloaded = (await TaskStore().load()).single;
    expect(reloaded.id, target.id);
    expect(reloaded.checklistOccurrences.keys.toSet(), dates.map((date) => date.toIso8601String()).toSet());
    for (var index = 0; index < 4; index++) {
      expect(
        reloaded.checklistOccurrences[dates[index].toIso8601String()],
        const ['[x] A', '[ ] B', '[x] C'],
      );
    }
    for (var index = 4; index < 7; index++) {
      expect(
        reloaded.checklistOccurrences[dates[index].toIso8601String()],
        const ['[ ] A', '[ ] B', '[ ] D'],
      );
    }
    expect(reloaded.occurrenceHistory[dates[4].toIso8601String()]?['status'], 'completed');
    expect(reloaded.occurrenceHistory[dates[5].toIso8601String()]?['status'], 'cancelled');

    final recurrenceRepository = TaskRecurrenceRepository(
      store: store,
      now: () => effectiveAt,
    );
    expect(
      await recurrenceRepository.checklistForOccurrence(target.id, dates[4]),
      const ['[ ] A', '[ ] B', '[ ] D'],
    );
    expect(
      await recurrenceRepository.checklistForOccurrence(target.id, dates[6]),
      const ['[ ] A', '[ ] B', '[ ] D'],
    );
    final notMaterialized = DateTime(2026, 10, 8, 6);
    expect(
      await recurrenceRepository.checklistForOccurrence(target.id, notMaterialized),
      const ['[ ] A', '[ ] B', '[ ] D'],
    );
    expect((await store.load()).single.checklistOccurrences, hasLength(7));
  });

  test('preserves identity history and non-editor lifecycle flags', () {
    final history = FollowUp(
      id: 'fu-history',
      dateTime: DateTime(2026, 8, 27, 10),
    );
    final createdAt = DateTime(2026, 8, 20);
    final target = Task(
      id: 'canonical-id',
      title: 'قبل',
      archived: true,
      trashed: true,
      completed: true,
      followUps: [history],
      createdAt: createdAt,
    );
    final edited = Task(
      id: 'different-editor-copy-id',
      title: 'بعد',
      archived: false,
      trashed: false,
      completed: false,
      followUps: const [],
      createdAt: DateTime(2026, 8, 28),
    );

    service.apply(target, edited);

    expect(target.id, 'canonical-id');
    expect(target.followUps, hasLength(1));
    expect(identical(target.followUps.single, history), isTrue);
    expect(target.createdAt, createdAt);
    expect(target.archived, isTrue);
    expect(target.trashed, isTrue);
    expect(target.completed, isFalse);
  });

  test('copies mutable collections instead of aliasing editor lists', () {
    final edited = Task(
      id: 'task-1',
      title: 'عنوان',
      tags: ['الف'],
      checklist: ['یک'],
    );
    final target = Task(id: 'task-1', title: 'قبل');

    service.apply(target, edited);
    edited.tags.add('ب');
    edited.checklist.add('دو');

    expect(target.tags, ['الف']);
    expect(target.checklist, ['یک']);
  });

  test('copies independent reminders and their sequence without list aliasing', () {
    final target = Task(id: 'reminders', title: 'کار');
    final edited = Task(
      id: 'reminders',
      title: 'کار',
      taskReminders: [
        TaskReminder(
          id: 'r1',
          title: 'یادآور ۱',
          date: DateTime(2026, 10, 20, 9),
          sequence: 1,
        ),
      ],
      nextReminderSequence: 2,
    );

    service.apply(target, edited);
    edited.taskReminders.clear();

    expect(target.taskReminders, hasLength(1));
    expect(target.taskReminders.single.id, 'r1');
    expect(target.nextReminderSequence, 2);
  });

  test('preserves unclassifiable occurrence keys while rebuilding valid current and future snapshots', () {
    final effectiveAt = DateTime(2026, 10, 5, 12);
    final malformedKey = 'legacy-occurrence-key';
    final past = DateTime(2026, 10, 4, 6).toIso8601String();
    final current = DateTime(2026, 10, 5, 6).toIso8601String();
    final future = DateTime(2026, 10, 6, 6).toIso8601String();
    const malformedSnapshot = <String>['[x] legacy'];
    const pastSnapshot = <String>['[x] A', '[ ] B', '[x] C'];
    final target = Task(
      id: 'malformed-key-task',
      title: 'Malformed key boundary',
      recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
      checklist: const ['[ ] A', '[ ] B', '[ ] C'],
      checklistOccurrences: <String, List<String>>{
        malformedKey: malformedSnapshot,
        past: pastSnapshot,
        current: const ['[x] A', '[x] B', '[x] C'],
        future: const ['[x] A', '[ ] B', '[x] C'],
      },
    );
    final edited = Task(
      id: 'editor-copy',
      title: 'Malformed key boundary',
      recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
      checklist: const ['[ ] A', '[ ] B', '[ ] D'],
    );

    TaskEditApplyService(now: () => effectiveAt).apply(target, edited);

    expect(target.checklistOccurrences.keys.toSet(), {malformedKey, past, current, future});
    expect(target.checklistOccurrences[malformedKey], malformedSnapshot);
    expect(target.checklistOccurrences[past], pastSnapshot);
    expect(target.checklistOccurrences[current], const ['[ ] A', '[ ] B', '[ ] D']);
    expect(target.checklistOccurrences[future], const ['[ ] A', '[ ] B', '[ ] D']);
  });

}
