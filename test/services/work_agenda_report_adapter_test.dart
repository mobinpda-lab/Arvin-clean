import 'package:arvin/models/task.dart';
import 'package:arvin/services/work_agenda_projection.dart';
import 'package:arvin/services/work_agenda_report_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const adapter = WorkAgendaReportAdapter();

  test('reuses canonical task report payload and keeps same-day reasons together', () {
    final task = Task(
      id: 'task-1',
      title: 'کار اصلی',
      description: 'شرح کامل',
      tags: ['مهم'],
      dueDate: DateTime(2026, 8, 28, 9),
      reminderDate: DateTime(2026, 8, 28, 8),
      followUpEnabled: true,
      followUps: [
        FollowUp(
          id: 'fu-1',
          dateTime: DateTime(2026, 8, 27, 10),
          nextFollowUp: DateTime(2026, 8, 28, 10),
        ),
      ],
    );

    final report = adapter.forDay(
      [task],
      day: DateTime(2026, 8, 28),
      generatedAt: DateTime(2026, 8, 28, 12),
    );

    expect(report.days, hasLength(1));
    expect(report.days.single.items, hasLength(1));
    final item = report.days.single.items.single;
    expect(item.entry.id, 'task-1');
    expect(item.entry.description, 'شرح کامل');
    expect(item.entry.tags, ['مهم']);
    expect(item.entry.followUps.single.id, 'fu-1');
    expect(
      item.events.map((event) => event.kind),
      [
        WorkAgendaEventKind.taskReminder,
        WorkAgendaEventKind.taskDue,
        WorkAgendaEventKind.followUpSchedule,
      ],
    );
  });

  test('range preserves agenda day grouping and allows same task on different days', () {
    final task = Task(
      id: 'task',
      title: 'چندروزه',
      dueDate: DateTime(2026, 8, 28, 9),
      reminderDate: DateTime(2026, 8, 29, 8),
    );

    final report = adapter.forRange(
      [task],
      startDay: DateTime(2026, 8, 28),
      endDay: DateTime(2026, 8, 29),
    );

    expect(report.days.map((day) => day.day), [
      DateTime(2026, 8, 28),
      DateTime(2026, 8, 29),
    ]);
    expect(report.days[0].items.single.entry.id, 'task');
    expect(report.days[1].items.single.entry.id, 'task');
    expect(report.days[0].items.single.events.single.kind,
        WorkAgendaEventKind.taskDue);
    expect(report.days[1].items.single.events.single.kind,
        WorkAgendaEventKind.taskReminder);
  });

  test('archived and trashed stay excluded while completed status remains truthful', () {
    final report = adapter.forDay(
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
          dueDate: DateTime(2026, 8, 28, 9),
          trashed: true,
        ),
        Task(
          id: 'done',
          title: 'انجام شده',
          dueDate: DateTime(2026, 8, 28, 10),
          completed: true,
        ),
      ],
      day: DateTime(2026, 8, 28),
    );

    expect(report.days.single.items.map((item) => item.entry.id), ['done']);
    expect(report.days.single.items.single.entry.completed, isTrue);
  });
}
