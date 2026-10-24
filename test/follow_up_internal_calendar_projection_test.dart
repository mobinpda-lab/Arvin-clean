import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_calendar_projection.dart';

void main() {
  const projection = FollowUpCalendarProjection();

  test('Next Follow-up and nested legacy reminder are retained as history but never projected', () {
    final task = Task(
      id: 'customer-call',
      title: 'تماس با مشتری',
      followUpEnabled: true,
      followUps: [
        FollowUp(
          id: 'follow-1',
          dateTime: DateTime(2026, 10, 13, 8),
          nextFollowUp: DateTime(2026, 10, 20, 10),
          reminderDate: DateTime(2026, 10, 20, 9, 55),
          note: 'تاریخچه تماس',
        ),
      ],
    );
    final before = task.toJson();
    expect(projection.project([task]), isEmpty);
    expect(task.toJson(), before);
    expect(task.followUps.single.nextFollowUp, DateTime(2026, 10, 20, 10));
    expect(task.followUps.single.reminderDate, DateTime(2026, 10, 20, 9, 55));
  });

  test('canonical Task Reminder projects while legacy Follow-up dates stay inactive', () {
    final task = Task(
      id: 'customer-call',
      title: 'تماس با مشتری',
      followUps: [
        FollowUp(
          id: 'follow-1',
          dateTime: DateTime(2026, 10, 13, 8),
          nextFollowUp: DateTime(2026, 10, 20, 10),
          reminderDate: DateTime(2026, 10, 20, 9, 55),
        ),
      ],
      taskReminders: [
        TaskReminder(
          id: 'r1',
          title: 'یادآوری تماس',
          date: DateTime(2026, 10, 20, 11),
          sequence: 1,
        ),
      ],
    );
    final before = task.toJson();
    final items = projection.project([task]);
    expect(items, hasLength(1));
    expect(items.single.id, 'task-reminder-item:customer-call:r1');
    expect(items.single.date, DateTime(2026, 10, 20, 11));
    expect(task.toJson(), before);
    expect(task.followUps, hasLength(1));
  });
}
