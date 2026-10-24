import 'dart:convert';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/work_agenda_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const projection = WorkAgendaProjection();

  test('one day combines Task due date and independent canonical Reminders', () {
    final day = DateTime(2026, 8, 28);
    final task = Task(
      id: 'task-1',
      title: 'کار اصلی',
      dueDate: DateTime(2026, 8, 28, 9),
      reminderDate: DateTime(2026, 8, 28, 8, 30),
      followUpEnabled: true,
      followUpDate: DateTime(2026, 8, 28, 6),
      followUps: [
        FollowUp(
          id: 'fu-old',
          dateTime: DateTime(2026, 8, 20, 10),
          reminderDate: DateTime(2026, 8, 28, 7, 45),
          nextFollowUp: DateTime(2026, 8, 28, 6, 30),
        ),
      ],
      taskReminders: [
        TaskReminder(id: 'r1', title: 'یادآور اول', date: DateTime(2026, 8, 28, 8, 30), sequence: 1),
        TaskReminder(id: 'r2', title: 'یادآور دوم', date: DateTime(2026, 8, 28, 8, 30), sequence: 2),
        TaskReminder(id: 'r3', title: 'یادآور دیگر', date: DateTime(2026, 8, 28, 11), sequence: 3),
      ],
    );

    final result = projection.forDay([task], day: day);
    expect(result, hasLength(1));
    expect(result.single.items, hasLength(1));
    final item = result.single.items.single;
    expect(item.taskId, 'task-1');
    expect(item.events.map((event) => event.kind), [
      WorkAgendaEventKind.taskReminder,
      WorkAgendaEventKind.taskReminder,
      WorkAgendaEventKind.taskDue,
      WorkAgendaEventKind.taskReminder,
    ]);
    expect(item.events.where((event) => event.reminderId != null).map((event) => event.reminderId).toSet(), {'r1', 'r2', 'r3'});
    expect(item.events.map((event) => event.stableKey).toSet(), hasLength(4));
  });

  test('all-day is explicit and midnight alone is not all-day', () {
    final day = DateTime(2026, 8, 28);
    final tasks = [
      Task(id: 'all-day', title: 'تمام‌روز', dueDate: day, allDay: true),
      Task(id: 'timed-midnight', title: 'نیمه‌شب ساعت‌دار', dueDate: day, allDay: false),
    ];
    final events = projection.forDay(tasks, day: day).expand((item) => item.items).expand((item) => item.events).toList();
    expect(events.map((event) => event.isAllDay), [true, false]);
  });

  test('inclusive range groups canonical due and Reminder events by local day', () {
    final task = Task(
      id: 'task',
      title: 'چندروزه',
      dueDate: DateTime(2026, 8, 28, 9),
      taskReminders: [
        TaskReminder(id: 'r1', title: 'فردا', date: DateTime(2026, 8, 29, 8), sequence: 1),
      ],
    );
    final result = projection.forRange(
      [task],
      startDay: DateTime(2026, 8, 28, 23),
      endDay: DateTime(2026, 8, 29, 1),
    );
    expect(result.map((entry) => entry.day), [DateTime(2026, 8, 28), DateTime(2026, 8, 29)]);
    expect(result[0].items.single.events.single.kind, WorkAgendaEventKind.taskDue);
    expect(result[1].items.single.events.single.kind, WorkAgendaEventKind.taskReminder);
  });

  test('legacy Next Follow-up and standalone legacy fields never fabricate agenda events', () {
    final task = Task(
      id: 'legacy',
      title: 'قدیمی',
      followUpEnabled: true,
      followUpDate: DateTime(2026, 8, 28, 12),
      reminderDate: DateTime(2026, 8, 28, 13),
      followUps: [
        FollowUp(
          id: 'fu',
          dateTime: DateTime(2026, 8, 27),
          nextFollowUp: DateTime(2026, 8, 28, 14),
          reminderDate: DateTime(2026, 8, 28, 15),
        ),
      ],
    );
    expect(projection.forDay([task], day: DateTime(2026, 8, 28)), isEmpty);
  });

  test('archived and trashed are excluded while completed canonical work remains reportable', () {
    final result = projection.forDay(
      [
        Task(id: 'archived', title: 'بایگانی', dueDate: DateTime(2026, 8, 28, 8), archived: true),
        Task(id: 'trashed', title: 'زباله', taskReminders: [TaskReminder(id: 'r1', title: 'x', date: DateTime(2026, 8, 28, 9), sequence: 1)], trashed: true),
        Task(id: 'completed', title: 'انجام شده', dueDate: DateTime(2026, 8, 28, 10), completed: true),
      ],
      day: DateTime(2026, 8, 28),
    );
    expect(result.single.items.map((item) => item.taskId), ['completed']);
    expect(result.single.items.single.completed, isTrue);
  });

  test('projection is read-only and range rejects invalid bounds', () {
    final task = Task(
      id: 'task',
      title: 'بدون تغییر',
      dueDate: DateTime(2026, 8, 28, 9),
      tags: ['الف'],
      followUps: [FollowUp(id: 'fu', dateTime: DateTime(2026, 8, 27), reminderDate: DateTime(2026, 8, 28, 8))],
      taskReminders: [TaskReminder(id: 'r1', title: 'یادآور', date: DateTime(2026, 8, 28, 8), sequence: 1)],
    );
    final before = jsonEncode(task.toJson());
    projection.forDay([task], day: DateTime(2026, 8, 28));
    expect(jsonEncode(task.toJson()), before);
    expect(
      () => projection.forRange(const <Task>[], startDay: DateTime(2026, 8, 29), endDay: DateTime(2026, 8, 28)),
      throwsArgumentError,
    );
  });
}
