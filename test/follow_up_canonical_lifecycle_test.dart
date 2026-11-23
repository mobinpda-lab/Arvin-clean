import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';

void main() {
  test('multiple follow-ups keep one canonical task and expose the latest entry', () {
    final first = DateTime(2026, 9, 19, 9, 0);
    final second = DateTime(2026, 9, 19, 14, 30);
    final task = Task(
      id: 'task-1',
      title: 'پیگیری مشتری',
      followUpEnabled: true,
      reminderDate: DateTime(2026, 9, 20, 10),
      followUps: [
        FollowUp(id: 'follow-1', dateTime: first, note: 'تماس اول'),
        FollowUp(id: 'follow-2', dateTime: second, note: 'تماس دوم'),
      ],
    );

    expect(task.id, 'task-1');
    expect(task.followUps, hasLength(2));
    expect(task.lastFollowUp?.id, 'follow-2');
    expect(task.lastFollowUpDate, second);
    expect(task.reminderDate, DateTime(2026, 9, 20, 10));
  });

  test('follow-up history survives serialization without changing task identity', () {
    final created = DateTime(2026, 9, 18, 8);
    final task = Task(
      id: 'task-2',
      title: 'پیگیری',
      createdAt: created,
      followUpEnabled: true,
      followUps: [
        FollowUp(
          id: 'follow-1',
          dateTime: DateTime(2026, 9, 18, 11),
          note: 'اول',
        ),
        FollowUp(
          id: 'follow-2',
          dateTime: DateTime(2026, 9, 19, 12),
          note: 'دوم',
        ),
      ],
    );

    final restored = Task.fromJson(task.toJson());

    expect(restored.id, 'task-2');
    expect(restored.createdAt, created);
    expect(restored.followUps.map((item) => item.id), ['follow-1', 'follow-2']);
    expect(restored.lastFollowUp?.id, 'follow-2');
  });
}
