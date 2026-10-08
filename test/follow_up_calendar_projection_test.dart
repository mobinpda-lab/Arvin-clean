import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/models/recurrence.dart';
import 'package:arvin/services/follow_up_calendar_projection.dart';

void main() {
  const projection = FollowUpCalendarProjection();

  test('projects a date-only due date as an all-day calendar event', () {
    final task = Task(
      id: 'date-only',
      title: 'کار روزانه',
      dueDate: DateTime(2026, 10, 8),
    );

    final reminders = const FollowUpCalendarProjection().project([task]);

    expect(reminders, hasLength(1));
    expect(reminders.single.id, 'task-due:date-only');
    expect(reminders.single.isAllDay, isTrue);
  });

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

  test('projects a task due date even without follow-up history', () {
    final dueDate = DateTime(2026, 10, 5, 14, 30);
    final task = Task(
      id: 'dated-task',
      title: 'ارسال پیش‌فاکتور',
      dueDate: dueDate,
    );

    final reminders = projection.project(<Task>[task]);

    expect(reminders, hasLength(1));
    expect(reminders.single.id, 'task-due:dated-task');
    expect(reminders.single.title, 'ارسال پیش‌فاکتور');
    expect(reminders.single.date, dueDate);
  });

  test('projects legacy follow-up date when canonical history is absent', () {
    final followUpDate = DateTime(2026, 11, 12, 9);
    final task = Task(
      id: 'legacy-followup',
      title: 'تماس مجدد',
      followUpEnabled: true,
      followUpDate: followUpDate,
    );

    final reminders = projection.project(<Task>[task]);

    expect(reminders, hasLength(1));
    expect(reminders.single.id, 'task-followup:legacy-followup');
    expect(reminders.single.date, followUpDate);
  });

  test('does not duplicate equivalent task and follow-up timestamps', () {
    final date = DateTime(2026, 12, 1, 10);
    final task = Task(
      id: 'dedupe',
      title: 'جلسه',
      dueDate: date,
      followUpEnabled: true,
      followUpDate: date,
      followUps: <FollowUp>[
        FollowUp(id: 'fu', dateTime: date),
      ],
    );

    final reminders = projection.project(<Task>[task]);

    expect(reminders, hasLength(1));
    expect(reminders.single.id, 'followup:dedupe:fu');
  });

  test('keeps distinct due date and follow-up timestamps visible', () {
    final task = Task(
      id: 'two-dates',
      title: 'قرارداد',
      dueDate: DateTime(2026, 12, 3, 16),
      followUps: <FollowUp>[
        FollowUp(id: 'fu', dateTime: DateTime(2026, 12, 3, 10)),
      ],
    );

    final reminders = projection.project(<Task>[task]);

    expect(reminders, hasLength(2));
    expect(reminders.map((item) => item.id), contains('task-due:two-dates'));
    expect(reminders.map((item) => item.id), contains('followup:two-dates:fu'));
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

  test('projects canonical FollowUp completion independently of parent task', () {
    final reminder = projection.project(<Task>[
      Task(
        id: 'active-task',
        title: 'کار فعال',
        completed: false,
        followUps: <FollowUp>[
          FollowUp(
            id: 'done-followup',
            dateTime: DateTime(2026, 9, 9, 12),
            completed: true,
          ),
        ],
      ),
    ]).single;

    expect(reminder.completed, isTrue);
  });

  test('projects a canonical task reminder separately from its due date', () {
    final reminderDate = DateTime(2026, 12, 5, 9);
    final dueDate = DateTime(2026, 12, 5, 14);
    final task = Task(
      id: 'task-reminder',
      title: 'تماس',
      reminderDate: reminderDate,
      dueDate: dueDate,
    );

    final reminders = projection.project(<Task>[task]);

    expect(reminders, hasLength(2));
    expect(reminders.map((item) => item.id), contains('task-reminder:task-reminder'));
    expect(reminders.map((item) => item.id), contains('task-due:task-reminder'));
  });

  test('projects a canonical task reminder independently from its due date', () {
    final reminderDate = DateTime(2026, 10, 6, 8, 30);
    final task = Task(
      id: 'task-reminder',
      title: 'تماس صبحگاهی',
      reminderDate: reminderDate,
      dueDate: DateTime(2026, 10, 6, 17),
    );

    final reminders = projection.project(<Task>[task]);

    expect(reminders, hasLength(2));
    expect(
      reminders.map((item) => item.id),
      contains('task-reminder:task-reminder'),
    );
    expect(
      reminders.firstWhere((item) => item.id == 'task-reminder:task-reminder').date,
      reminderDate,
    );
  });

  test('projects only the next five recurring occurrences', () {
    final task = Task(
      id: 'daily-task',
      title: 'کار روزانه',
      dueDate: DateTime(2026, 10, 1, 14),
      recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
    );

    final reminders = projection.project(
      <Task>[task],
      visibleFrom: DateTime(2026, 10, 8),
      visibleTo: DateTime(2026, 10, 20),
      now: DateTime(2026, 10, 8, 8),
    );

    expect(reminders, hasLength(5));
    expect(reminders.map((item) => item.date), <DateTime>[
      DateTime(2026, 10, 8, 14),
      DateTime(2026, 10, 9, 14),
      DateTime(2026, 10, 10, 14),
      DateTime(2026, 10, 11, 14),
      DateTime(2026, 10, 12, 14),
    ]);
    expect(reminders.map((item) => item.id).toSet().length, reminders.length);
  });

  test('rolling repeat window adds the next occurrence as one occurrence passes', () {
    final task = Task(
      id: 'rolling-daily',
      title: 'کار چرخشی',
      dueDate: DateTime(2026, 10, 1, 14),
      recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
    );

    final reminders = projection.project(
      <Task>[task],
      visibleFrom: DateTime(2026, 10, 9),
      visibleTo: DateTime(2026, 10, 20),
      now: DateTime(2026, 10, 9, 15),
    );

    expect(reminders.map((item) => item.date), <DateTime>[
      DateTime(2026, 10, 10, 14),
      DateTime(2026, 10, 11, 14),
      DateTime(2026, 10, 12, 14),
      DateTime(2026, 10, 13, 14),
      DateTime(2026, 10, 14, 14),
    ]);
  });

  test('projects custom minute recurrence without creating independent tasks', () {
    final task = Task(
      id: 'short-cycle',
      title: 'کار کوتاه',
      dueDate: DateTime(2026, 10, 1, 23, 40),
      recurrence: const RecurrenceRule(
        frequency: RecurrenceFrequency.minutes,
        interval: 20,
      ),
    );

    final reminders = projection.project(
      <Task>[task],
      visibleFrom: DateTime(2026, 10, 2),
      visibleTo: DateTime(2026, 10, 2, 1, 1),
      now: DateTime(2026, 10, 2),
    );

    expect(reminders, hasLength(4));
    expect(reminders.first.id, startsWith('task-due:short-cycle:'));
    expect(reminders.map((item) => item.title).toSet(), {'کار کوتاه'});
  });

  test('weekly recurrence respects the visible range and does not leak other dates', () {
    final task = Task(
      id: 'weekly-task',
      title: 'کار هفتگی',
      dueDate: DateTime(2026, 10, 3, 9),
      recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.weekly),
    );

    final reminders = projection.project(
      <Task>[task],
      visibleFrom: DateTime(2026, 10, 5),
      visibleTo: DateTime(2026, 10, 20),
    );

    expect(reminders, hasLength(2));
    expect(reminders[0].date, DateTime(2026, 10, 10, 9));
    expect(reminders[1].date, DateTime(2026, 10, 17, 9));
  });
}
