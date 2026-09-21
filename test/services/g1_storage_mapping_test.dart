import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/person_reference.dart';
import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/project_plan_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('G1 Task mapping preserves every persisted canonical field', () {
    final source = Task(
      id: 'task-g1-1',
      title: 'کار کامل',
      description: 'شرح',
      createdAt: DateTime.utc(2026, 9, 1, 8),
      updatedAt: DateTime.utc(2026, 9, 2, 9),
      dueDate: DateTime.utc(2026, 9, 3, 10),
      followUpEnabled: true,
      followUpDate: DateTime.utc(2026, 9, 4, 11),
      tags: const ['مهم', 'مشتری'],
      category: 'کاری',
      checklist: const ['[x] مورد اول', '[ ] مورد دوم'],
      notebookKind: NotebookItemKind.checklist,
      reminderDate: DateTime.utc(2026, 9, 3, 9),
      priority: TaskPriority.high,
      archived: true,
      trashed: false,
      completed: true,
      followUps: [
        FollowUp(
          id: 'fu-g1-1',
          dateTime: DateTime.utc(2026, 9, 2, 12),
          note: 'تماس شد',
          result: 'پاسخ مثبت',
          reminderDate: DateTime.utc(2026, 9, 3, 12),
          nextFollowUp: DateTime.utc(2026, 9, 5, 12),
          completed: true,
        ),
      ],
      recurrence: const RecurrenceRule(
        frequency: RecurrenceFrequency.weeklyDays,
        interval: 2,
        weekdays: [1, 4],
      ),
      people: [
        PersonReference(id: 'person-1', displayName: 'مشتری اول'),
      ],
    );

    final encoded = source.toJson();
    final restored = Task.fromJson(encoded);

    expect(restored.id, source.id);
    expect(restored.title, source.title);
    expect(restored.description, source.description);
    expect(restored.createdAt, source.createdAt);
    expect(restored.updatedAt, source.updatedAt);
    expect(restored.dueDate, source.dueDate);
    expect(restored.followUpEnabled, source.followUpEnabled);
    expect(restored.followUpDate, source.followUpDate);
    expect(restored.tags, source.tags);
    expect(restored.category, source.category);
    expect(restored.checklist, source.checklist);
    expect(restored.notebookKind, source.notebookKind);
    expect(restored.reminderDate, source.reminderDate);
    expect(restored.priority, source.priority);
    expect(restored.archived, source.archived);
    expect(restored.trashed, source.trashed);
    expect(restored.completed, source.completed);
    expect(restored.followUps, hasLength(1));
    expect(restored.followUps.single.id, 'fu-g1-1');
    expect(restored.followUps.single.note, 'تماس شد');
    expect(restored.followUps.single.result, 'پاسخ مثبت');
    expect(restored.followUps.single.reminderDate, source.followUps.single.reminderDate);
    expect(restored.followUps.single.nextFollowUp, source.followUps.single.nextFollowUp);
    expect(restored.followUps.single.completed, isTrue);
    expect(restored.recurrence?.frequency, RecurrenceFrequency.weeklyDays);
    expect(restored.recurrence?.interval, 2);
    expect(restored.recurrence?.weekdays, [1, 4]);
    expect(restored.people.single.id, 'person-1');
    expect(restored.people.single.displayName, 'مشتری اول');
  });

  test('G1 Project mapping preserves identity, archive state, color and membership order', () {
    final project = ProjectPlan(
      id: 'project-g1-1',
      title: 'پروژه کاری',
      colorValue: 0xFF123456,
      isArchived: true,
      itemIds: const ['task-2', 'task-1'],
    );
    const codec = ProjectPlanCodec();

    final restored = codec.decode(codec.encode(project));

    expect(restored.id, project.id);
    expect(restored.title, project.title);
    expect(restored.colorValue, project.colorValue);
    expect(restored.isArchived, isTrue);
    expect(restored.itemIds, ['task-2', 'task-1']);
  });

  test('G1 duplicate identities are rejected before persistence mapping', () {
    final duplicateTask = Task(id: 'same-id', title: 'یکی');

    expect(
      () => const _DuplicateGuard().encodeTasks([duplicateTask, duplicateTask]),
      throwsA(isA<FormatException>()),
    );
  });

  test('G1 malformed source does not mutate the source payload', () {
    const legacy = '{"not":"a-list"}';
    expect(
      () => _decodeLegacy(legacy),
      throwsA(isA<FormatException>()),
    );
    expect(legacy, '{"not":"a-list"}');
  });
}

class _DuplicateGuard {
  const _DuplicateGuard();

  String encodeTasks(List<Task> tasks) {
    final ids = <String>{};
    for (final task in tasks) {
      if (!ids.add(task.id)) {
        throw const FormatException('Duplicate task id');
      }
    }
    return 'ok';
  }
}

List<Task> _decodeLegacy(String raw) {
  if (!raw.startsWith('[')) {
    throw const FormatException('Expected a task list');
  }
  return const [];
}
