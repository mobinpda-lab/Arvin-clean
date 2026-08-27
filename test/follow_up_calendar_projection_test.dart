import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_calendar_projection.dart';

void main() {
  const projection = FollowUpCalendarProjection();

  test('projects canonical follow-up history in chronological order', () {
    final tasks = <Task>[
      Task(
        id: 'task-1',
        title: 'تماس با مشتری',
        followUps: <FollowUp>[
          FollowUp(
            id: 'fu-2',
            dateTime: DateTime(2026, 8, 27, 10),
            note: 'پیگیری قرارداد',
          ),
          FollowUp(
            id: 'fu-1',
            dateTime: DateTime(2026, 8, 26, 9),
          ),
        ],
      ),
    ];

    final reminders = projection.project(tasks);

    expect(reminders, hasLength(2));
    expect(reminders.first.id, 'followup:task-1:fu-1');
    expect(reminders.first.title, 'تماس با مشتری');
    expect(reminders.last.title, 'تماس با مشتری — پیگیری قرارداد');
    expect(reminders.last.date, DateTime(2026, 8, 27, 10));
  });

  test('resolves a projected reminder back to its exact canonical target', () {
    final followUp = FollowUp(
      id: 'fu-1',
      dateTime: DateTime(2026, 8, 27, 10),
      note: 'پیگیری قرارداد',
    );
    final task = Task(
      id: 'task-1',
      title: 'تماس با مشتری',
      followUps: <FollowUp>[followUp],
    );

    final reminder = projection.project(<Task>[task]).single;
    final target = projection.resolveTarget(<Task>[task], reminder.id);

    expect(target, isNotNull);
    expect(target!.taskId, task.id);
    expect(target.followUp, same(followUp));
  });

  test('resolves ids containing colons without parsing string segments', () {
    final followUp = FollowUp(
      id: 'fu:part:2',
      dateTime: DateTime(2026, 8, 27, 11),
    );
    final task = Task(
      id: 'task:customer:42',
      title: 'جلسه',
      followUps: <FollowUp>[followUp],
    );

    final reminder = projection.project(<Task>[task]).single;
    final target = projection.resolveTarget(<Task>[task], reminder.id);

    expect(reminder.id, 'followup:task:customer:42:fu:part:2');
    expect(target, isNotNull);
    expect(target!.taskId, 'task:customer:42');
    expect(target.followUp.id, 'fu:part:2');
  });

  test('does not resolve trashed or unknown reminder targets', () {
    final trashed = Task(
      id: 'trash',
      title: 'حذف شده',
      trashed: true,
      followUps: <FollowUp>[
        FollowUp(id: 'fu', dateTime: DateTime(2026, 8, 25)),
      ],
    );

    expect(
      projection.resolveTarget(<Task>[trashed], 'followup:trash:fu'),
      isNull,
    );
    expect(
      projection.resolveTarget(<Task>[], 'followup:missing:fu'),
      isNull,
    );
  });

  test('excludes trashed tasks and preserves completed state', () {
    final reminders = projection.project(<Task>[
      Task(
        id: 'done',
        title: 'انجام شده',
        completed: true,
        followUps: <FollowUp>[
          FollowUp(id: 'fu', dateTime: DateTime(2026, 8, 25)),
        ],
      ),
      Task(
        id: 'trash',
        title: 'حذف شده',
        trashed: true,
        followUps: <FollowUp>[
          FollowUp(id: 'fu', dateTime: DateTime(2026, 8, 25)),
        ],
      ),
    ]);

    expect(reminders, hasLength(1));
    expect(reminders.single.id, 'followup:done:fu');
    expect(reminders.single.completed, isTrue);
  });
}
