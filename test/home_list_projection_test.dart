import 'package:arvin/models/task.dart';
import 'package:arvin/services/home_list_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 27, 12);
  const projection = HomeListProjection();

  Task task(
    String id, {
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool completed = false,
    bool archived = false,
    bool trashed = false,
    List<FollowUp> followUps = const [],
  }) =>
      Task(
        id: id,
        title: id,
        dueDate: dueDate,
        createdAt: createdAt,
        updatedAt: updatedAt,
        completed: completed,
        archived: archived,
        trashed: trashed,
        followUps: followUps,
      );

  test('home reminder projection keeps Task reminders independent and deduplicates reminder timestamps', () {
    final followUpAt = now.add(const Duration(hours: 2));
    final duplicateAt = now.add(const Duration(hours: 1));
    final reminders = <TaskReminder>[
      TaskReminder(id: 'same-as-follow-up', title: 'پیگیری هم‌زمان', date: followUpAt, sequence: 1),
      TaskReminder(id: 'first-at-time', title: 'یادآور اول', date: duplicateAt, sequence: 2),
      TaskReminder(id: 'second-at-time', title: 'یادآور دوم', date: duplicateAt, sequence: 3),
      TaskReminder(id: 'unique-time', title: 'یادآور دیگر', date: now.add(const Duration(hours: 3)), sequence: 4),
    ];

    final projected = projection.projectReminders(reminders, followUpDate: followUpAt);

    expect(projected.map((item) => item.id), ['same-as-follow-up', 'first-at-time', 'unique-time']);
    expect(reminders, hasLength(4));
    expect(identical(projected.first, reminders[0]), isTrue);

    final coincident = task(
      'coincident',
      dueDate: followUpAt,
      followUps: [
        FollowUp(
          id: 'same-time-follow-up',
          dateTime: followUpAt.subtract(const Duration(days: 2)),
          nextFollowUp: followUpAt,
        ),
      ],
    );
    final distinct = task(
      'distinct',
      dueDate: followUpAt.add(const Duration(minutes: 1)),
      followUps: [FollowUp(id: 'other-time-follow-up', dateTime: followUpAt)],
    );
    expect(projection.shouldProjectDueDate(coincident), isTrue);
    expect(projection.shouldProjectDueDate(distinct), isTrue);
  });
}
