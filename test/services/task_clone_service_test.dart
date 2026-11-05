import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_clone_service.dart';

void main() {
  const service = TaskCloneService();

  test('clone creates a new independent Task and clears history and alarms', () {
    final due = DateTime(2026, 11, 8, 9, 30);
    final created = DateTime(2026, 10, 1, 8);
    final source = Task(
      id: 'source-1',
      title: 'بررسی گزارش',
      description: 'شرح کامل',
      createdAt: created,
      updatedAt: created,
      dueDate: due,
      checklist: const ['[ ] بررسی'],
      checklistEnabled: true,
      taskReminders: [
        TaskReminder(id: 'r1', title: 'اعلان', date: due, sequence: 1),
      ],
      followUps: [
        FollowUp(id: 'f1', dateTime: created, note: 'سابقه'),
      ],
      completed: true,
      completedAt: created,
      occurrenceHistory: const {'2026-10-01': {'status': 'completed'}},
      checklistOccurrences: const {'2026-10-01': ['[x] بررسی']},
      templateTaskId: 'template-task-1',
    );

    final at = DateTime(2026, 11, 4, 12);
    final clone = service.clone(source, at: at, id: 'clone-1');

    expect(clone.id, 'clone-1');
    expect(clone.title, 'بررسی گزارش — رونوشت');
    expect(clone.description, source.description);
    expect(clone.dueDate, due);
    expect(clone.checklist, source.checklist);
    expect(clone.templateTaskId, source.templateTaskId);
    expect(clone.completed, isFalse);
    expect(clone.completedAt, isNull);
    expect(clone.followUps, isEmpty);
    expect(clone.taskReminders, isEmpty);
    expect(clone.reminderDate, isNull);
    expect(clone.followUpEnabled, isFalse);
    expect(clone.followUpDate, isNull);
    expect(clone.occurrenceHistory, isEmpty);
    expect(clone.checklistOccurrences, isEmpty);
    expect(clone.createdAt, at);
    expect(clone.updatedAt, at);
  });

  test('clone title avoids stacked suffixes and occupied names', () {
    expect(service.uniqueCloneTitle('عنوان', const []), 'عنوان — رونوشت');
    expect(
      service.uniqueCloneTitle('عنوان — رونوشت', const ['عنوان — رونوشت']),
      'عنوان — رونوشت ۲',
    );
    expect(
      service.uniqueCloneTitle('عنوان — رونوشت ۲', const [
        'عنوان — رونوشت',
        'عنوان — رونوشت ۲',
      ]),
      'عنوان — رونوشت ۳',
    );
    expect(
      service.uniqueCloneTitle('عنوان', const [
        'عنوان — رونوشت',
        'عنوان — رونوشت ۲',
        'عنوان — رونوشت ۳',
      ]),
      'عنوان — رونوشت ۴',
    );
  });

  test('clone never reuses source identity when id is not supplied', () {
    final source = Task(id: 'source-2', title: 'کار');
    final clone = service.clone(
      source,
      at: DateTime(2026, 11, 4, 12),
    );
    expect(clone.id, isNot('source-2'));
  });
}
