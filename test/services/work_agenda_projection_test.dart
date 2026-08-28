import 'dart:convert';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/work_agenda_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const projection = WorkAgendaProjection();

  test('one day combines all canonical work reasons without duplicating Task', () {
    final day = DateTime(2026, 8, 28);
    final task = Task(
      id: 'task-1',
      title: 'کار اصلی',
      dueDate: DateTime(2026, 8, 28, 9),
      reminderDate: DateTime(2026, 8, 28, 8, 30),
      followUpEnabled: true,
      followUps: [
        FollowUp(
          id: 'fu-old',
          dateTime: DateTime(2026, 8, 20, 10),
          reminderDate: DateTime(2026, 8, 28, 7, 45),
          nextFollowUp: DateTime(2026, 8, 28, 6),
        ),
        FollowUp(
          id: 'fu-latest',
          dateTime: DateTime(2026, 8, 27, 10),
          reminderDate: DateTime(2026, 8, 28, 11),
          nextFollowUp: DateTime(2026, 8, 28, 10),
        ),
      ],
    );

    final result = projection.forDay([task], day: day);

    expect(result, hasLength(1));
    expect(result.single.items, hasLength(1));
    final item = result.single.items.single;
    expect(item.taskId, 'task-1');
    expect(
      item.events.map((event) => event.kind),
      [
        WorkAgendaEventKind.followUpReminder,
        WorkAgendaEventKind.taskReminder,
        WorkAgendaEventKind.taskDue,
        WorkAgendaEventKind.followUpSchedule,
        WorkAgendaEventKind.followUpReminder,
      ],
    );
    expect(
      item.events
          .where((event) => event.kind == WorkAgendaEventKind.followUpSchedule)
          .single
          .followUpId,
      'fu-latest',
    );
    expect(
      item.events.any(
        (event) =>
            event.kind == WorkAgendaEventKind.followUpSchedule &&
            event.followUpId == 'fu-old',
      ),
      isFalse,
    );
  });

  test('inclusive range groups by local day and keeps deterministic order', () {
    final tasks = [
      Task(
        id: 'b',
        title: 'ب',
        dueDate: DateTime(2026, 8, 29, 9),
      ),
      Task(
        id: 'a',
        title: 'الف',
        reminderDate: DateTime(2026, 8, 28, 10),
      ),
      Task(
        id: 'c',
        title: 'ج',
        dueDate: DateTime(2026, 8, 30, 8),
      ),
      Task(
        id: 'aa',
        title: 'الف دوم',
        dueDate: DateTime(2026, 8, 28, 10),
      ),
    ];

    final result = projection.forRange(
      tasks,
      startDay: DateTime(2026, 8, 28, 23),
      endDay: DateTime(2026, 8, 29, 1),
    );

    expect(result.map((entry) => entry.day), [
      DateTime(2026, 8, 28),
      DateTime(2026, 8, 29),
    ]);
    expect(result.first.items.map((item) => item.taskId), ['a', 'aa']);
    expect(result.last.items.single.taskId, 'b');
    expect(result.expand((day) => day.items).any((item) => item.taskId == 'c'),
        isFalse);
  });

  test('same Task may appear on different range days for different work events', () {
    final task = Task(
      id: 'task',
      title: 'چندروزه',
      dueDate: DateTime(2026, 8, 28, 9),
      reminderDate: DateTime(2026, 8, 29, 8),
    );

    final result = projection.forRange(
      [task],
      startDay: DateTime(2026, 8, 28),
      endDay: DateTime(2026, 8, 29),
    );

    expect(result, hasLength(2));
    expect(result[0].items.single.taskId, 'task');
    expect(result[0].items.single.events.single.kind,
        WorkAgendaEventKind.taskDue);
    expect(result[1].items.single.taskId, 'task');
    expect(result[1].items.single.events.single.kind,
        WorkAgendaEventKind.taskReminder);
  });

  test('archived and trashed are excluded while completed work stays truthful', () {
    final day = DateTime(2026, 8, 28);
    final result = projection.forDay(
      [
        Task(
          id: 'archived',
          title: 'بایگانی',
          dueDate: DateTime(2026, 8, 28, 8),
          archived: true,
        ),
        Task(
          id: 'trashed',
          title: 'زباله',
          reminderDate: DateTime(2026, 8, 28, 9),
          trashed: true,
        ),
        Task(
          id: 'completed',
          title: 'انجام شده',
          dueDate: DateTime(2026, 8, 28, 10),
          completed: true,
        ),
      ],
      day: day,
    );

    expect(result.single.items.map((item) => item.taskId), ['completed']);
    expect(result.single.items.single.completed, isTrue);
  });

  test('legacy Task followUpDate does not fabricate agenda work', () {
    final task = Task(
      id: 'legacy',
      title: 'قدیمی',
      followUpEnabled: true,
      followUpDate: DateTime(2026, 8, 28, 12),
    );

    final result = projection.forDay([task], day: DateTime(2026, 8, 28));

    expect(result, isEmpty);
  });

  test('older nextFollowUp is superseded by latest real FollowUp', () {
    final task = Task(
      id: 'task',
      title: 'پیگیری',
      followUpEnabled: true,
      followUps: [
        FollowUp(
          id: 'old',
          dateTime: DateTime(2026, 8, 20),
          nextFollowUp: DateTime(2026, 8, 28, 10),
        ),
        FollowUp(
          id: 'latest',
          dateTime: DateTime(2026, 8, 27),
        ),
      ],
    );

    final result = projection.forDay([task], day: DateTime(2026, 8, 28));

    expect(result, isEmpty);
  });

  test('projection is read-only over canonical Task and FollowUp data', () {
    final task = Task(
      id: 'task',
      title: 'بدون تغییر',
      dueDate: DateTime(2026, 8, 28, 9),
      tags: ['الف'],
      followUpEnabled: true,
      followUps: [
        FollowUp(
          id: 'fu',
          dateTime: DateTime(2026, 8, 27),
          reminderDate: DateTime(2026, 8, 28, 8),
        ),
      ],
    );
    final before = jsonEncode(task.toJson());

    projection.forDay([task], day: DateTime(2026, 8, 28));

    expect(jsonEncode(task.toJson()), before);
  });

  test('range rejects end day before start day', () {
    expect(
      () => projection.forRange(
        const <Task>[],
        startDay: DateTime(2026, 8, 29),
        endDay: DateTime(2026, 8, 28),
      ),
      throwsArgumentError,
    );
  });
}
