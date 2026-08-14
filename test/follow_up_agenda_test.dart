import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_agenda.dart';

void main() {
  final tasks = [
    Task(
      id: 't1',
      title: 'اول',
      followUps: const [
        FollowUp(
          id: 'f2',
          dateTime: DateTime(2026, 8, 20, 10),
          nextFollowUp: DateTime(2026, 8, 25, 10),
        ),
        FollowUp(
          id: 'f1',
          dateTime: DateTime(2026, 8, 15, 9),
          nextFollowUp: DateTime(2026, 8, 18, 9),
        ),
      ],
    ),
    Task(
      id: 't2',
      title: 'دوم',
      followUps: const [
        FollowUp(
          id: 'f3',
          dateTime: DateTime(2026, 8, 17, 11),
        ),
      ],
    ),
  ];

  test('builds chronological follow-up history across tasks', () {
    const agenda = FollowUpAgenda();
    final items = agenda.build(tasks);

    expect(items.map((item) => item.followUp.id), ['f1', 'f3', 'f2']);
  });

  test('futureOnly removes historical follow-ups', () {
    const agenda = FollowUpAgenda();
    final items = agenda.build(
      tasks,
      from: DateTime(2026, 8, 18),
      futureOnly: true,
    );

    expect(items.map((item) => item.followUp.id), ['f2']);
  });

  test('upcomingNext sorts by next-follow-up date', () {
    const agenda = FollowUpAgenda();
    final items = agenda.upcomingNext(
      tasks,
      from: DateTime(2026, 8, 17),
    );

    expect(items.map((item) => item.followUp.id), ['f1', 'f2']);
  });
}
