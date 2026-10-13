import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_calendar_projection.dart';
import 'package:arvin/services/follow_up_internal_calendar_projection.dart';

void main() {
  const internal = FollowUpInternalCalendarProjection();
  const reminders = FollowUpCalendarProjection();

  test('nextFollowUp appears only in internal projection, not reminder projection', () {
    final task = Task(
      id: 'customer-call',
      title: 'تماس با مشتری',
      followUpEnabled: true,
      followUps: [
        FollowUp(
          id: 'follow-1',
          dateTime: DateTime(2026, 10, 13, 8),
          nextFollowUp: DateTime(2026, 10, 20, 10),
        ),
      ],
    );

    final before = task.toJson();
    final internalItems = internal.project([task]);
    final reminderItems = reminders.project([task]);

    expect(internalItems, hasLength(1));
    expect(internalItems.single.id, 'task-followup-action:customer-call:follow-1');
    expect(internalItems.single.title, 'تماس با مشتری');
    expect(internalItems.single.date, DateTime(2026, 10, 20, 10));
    expect(reminderItems, isEmpty);
    expect(task.toJson(), before);
  });

  test('explicit Reminder takes calendar precedence without mutating Follow-up', () {
    final task = Task(
      id: 'customer-call',
      title: 'تماس با مشتری',
      reminderDate: DateTime(2026, 10, 20, 9, 55),
      followUps: [
        FollowUp(
          id: 'follow-1',
          dateTime: DateTime(2026, 10, 13, 8),
          nextFollowUp: DateTime(2026, 10, 20, 10),
          reminderDate: DateTime(2026, 10, 20, 9, 55),
        ),
      ],
    );

    final before = task.toJson();
    final actionItems = internal.project([task]);
    final reminderItems = reminders.project([task]);

    expect(actionItems, isEmpty);
    expect(reminderItems.any((item) => item.date == DateTime(2026, 10, 20, 9, 55)), isTrue);
    expect(task.followUps.single.nextFollowUp, DateTime(2026, 10, 20, 10));
    expect(task.toJson(), before);
  });

  test('Reminder precedence is scoped to its own Task', () {
    final withReminder = Task(
      id: 'task-with-reminder',
      title: 'دارای یادآور',
      reminderDate: DateTime(2026, 10, 20, 9),
      followUps: [
        FollowUp(
          id: 'follow-with-reminder',
          dateTime: DateTime(2026, 10, 13, 8),
          nextFollowUp: DateTime(2026, 10, 20, 10),
        ),
      ],
    );
    final withoutReminder = Task(
      id: 'task-without-reminder',
      title: 'بدون یادآور',
      followUps: [
        FollowUp(
          id: 'follow-without-reminder',
          dateTime: DateTime(2026, 10, 13, 8),
          nextFollowUp: DateTime(2026, 10, 21, 10),
        ),
      ],
    );

    final items = internal.project([withReminder, withoutReminder]);
    expect(items, hasLength(1));
    expect(items.single.id,
        'task-followup-action:task-without-reminder:follow-without-reminder');
  });

  test('changing nextFollowUp does not mutate existing reminderDate', () {
    final originalReminder = DateTime(2026, 10, 20, 9, 55);
    final task = Task(
      id: 'customer-call',
      title: 'تماس با مشتری',
      followUps: [
        FollowUp(
          id: 'follow-1',
          dateTime: DateTime(2026, 10, 13, 8),
          nextFollowUp: DateTime(2026, 10, 20, 10),
          reminderDate: originalReminder,
        ),
      ],
    );

    final followUp = task.followUps.single;
    final changed = FollowUp(
      id: followUp.id,
      dateTime: followUp.dateTime,
      note: followUp.note,
      result: followUp.result,
      reminderDate: followUp.reminderDate,
      nextFollowUp: DateTime(2026, 10, 21, 10),
      completed: followUp.completed,
    );

    expect(changed.nextFollowUp, DateTime(2026, 10, 21, 10));
    expect(changed.reminderDate, originalReminder);
    expect(reminders.project([task]).single.date, originalReminder);

    // The existing Reminder wins the internal calendar display. The action
    // date remains independently editable in canonical Follow-up data.
    expect(internal.project([task]), isEmpty);
    // Clearing the Reminder is an explicit, independent operation. Once
    // cleared, the still-existing nextFollowUp becomes visible internally.
    final followUpWithoutReminder = FollowUp(
      id: changed.id,
      dateTime: changed.dateTime,
      note: changed.note,
      result: changed.result,
      nextFollowUp: changed.nextFollowUp,
      completed: changed.completed,
    );
    final taskWithoutReminder = Task(
      id: task.id,
      title: task.title,
      followUps: [followUpWithoutReminder],
    );
    expect(internal.project([taskWithoutReminder]).single.date,
        DateTime(2026, 10, 21, 10));
  });
}
