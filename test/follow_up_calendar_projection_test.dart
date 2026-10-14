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
            reminderDate: DateTime(2026, 8, 28, 11),
          ),
          FollowUp(
            id: 'fu-1',
            dateTime: DateTime(2026, 8, 26, 9),
            reminderDate: DateTime(2026, 8, 27, 9),
          ),
        ],
      ),
    ];

    final reminders = projection.project(tasks);

    expect(reminders, hasLength(2));
    expect(reminders.first.id, 'followup:task-1:fu-1');
    expect(reminders.first.title, 'تماس با مشتری');
    expect(reminders.first.date, DateTime(2026, 8, 27, 9));
    expect(reminders.last.title, 'تماس با مشتری — پیگیری قرارداد');
    expect(reminders.last.date, DateTime(2026, 8, 28, 11));
  });

  test('does not project follow-up history when no independent reminder is configured', () {
    final task = Task(
      id: 'history-only',
      title: 'پیگیری بدون یادآور',
      followUps: <FollowUp>[
        FollowUp(
          id: 'fu-history',
          dateTime: DateTime(2026, 10, 12, 10),
        ),
      ],
    );

    expect(projection.project(<Task>[task]), isEmpty);
    expect(
      projection.resolveTarget(<Task>[task], 'followup:history-only:fu-history'),
      isNull,
    );
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

  test('does not project a legacy follow-up date without an independent reminder', () {
    final followUpDate = DateTime(2026, 11, 12, 9);
    final task = Task(
      id: 'legacy-followup',
      title: 'تماس مجدد',
      followUpEnabled: true,
      followUpDate: followUpDate,
    );

    final reminders = projection.project(<Task>[task]);

    expect(reminders, isEmpty);
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
        FollowUp(id: 'fu', dateTime: date, reminderDate: date),
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
        FollowUp(
          id: 'fu',
          dateTime: DateTime(2026, 12, 3, 10),
          reminderDate: DateTime(2026, 12, 3, 11),
        ),
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
      reminderDate: DateTime(2026, 8, 28, 10),
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
      reminderDate: DateTime(2026, 8, 28, 11),
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
          FollowUp(
            id: 'fu',
            dateTime: DateTime(2026, 8, 25),
            reminderDate: DateTime(2026, 8, 26),
          ),
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
            reminderDate: DateTime(2026, 9, 10, 8),
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

  test('projects past, today, and future occurrences in the visible range', () {
    final task = Task(
      id: 'daily-task',
      title: 'کار روزانه',
      dueDate: DateTime(2026, 10, 1, 14),
      recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
    );

    final reminders = projection.project(
      <Task>[task],
      visibleFrom: DateTime(2026, 10, 5),
      visibleTo: DateTime(2026, 10, 12),
      now: DateTime(2026, 10, 8, 15),
    );

    expect(reminders.map((item) => item.date), <DateTime>[
      DateTime(2026, 10, 5, 14),
      DateTime(2026, 10, 6, 14),
      DateTime(2026, 10, 7, 14),
      DateTime(2026, 10, 8, 14),
      DateTime(2026, 10, 9, 14),
      DateTime(2026, 10, 10, 14),
      DateTime(2026, 10, 11, 14),
    ]);
    expect(reminders.map((item) => item.id).toSet().length, reminders.length);
  });

  test('projects a visible range beyond the next seven occurrences', () {
    final task = Task(
      id: 'later-range',
      title: 'کار آینده',
      dueDate: DateTime(2026, 10, 1, 14),
      recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
    );

    final reminders = projection.project(
      <Task>[task],
      visibleFrom: DateTime(2026, 10, 15),
      visibleTo: DateTime(2026, 10, 27),
      now: DateTime(2026, 10, 8, 8),
    );

    expect(reminders.map((item) => item.date), <DateTime>[
      DateTime(2026, 10, 15, 14),
      DateTime(2026, 10, 16, 14),
      DateTime(2026, 10, 17, 14),
      DateTime(2026, 10, 18, 14),
      DateTime(2026, 10, 19, 14),
      DateTime(2026, 10, 20, 14),
      DateTime(2026, 10, 21, 14),
      DateTime(2026, 10, 22, 14),
      DateTime(2026, 10, 23, 14),
      DateTime(2026, 10, 24, 14),
      DateTime(2026, 10, 25, 14),
      DateTime(2026, 10, 26, 14),
    ]);
  });

  test('respects recurrence count and end-date boundaries in visible range', () {
    final task = Task(
      id: 'bounded-range',
      title: 'کار محدود',
      dueDate: DateTime(2026, 10, 1, 14),
      recurrence: RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        count: 7,
        endDate: DateTime(2026, 10, 8),
      ),
    );

    final reminders = projection.project(
      <Task>[task],
      visibleFrom: DateTime(2026, 10, 4),
      visibleTo: DateTime(2026, 10, 12),
      now: DateTime(2026, 10, 8, 15),
    );

    expect(reminders.map((item) => item.date), <DateTime>[
      DateTime(2026, 10, 4, 14),
      DateTime(2026, 10, 5, 14),
      DateTime(2026, 10, 6, 14),
      DateTime(2026, 10, 7, 14),
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
    expect(reminders.map((item) => item.date), <DateTime>[
      DateTime(2026, 10, 10, 9),
      DateTime(2026, 10, 17, 9),
    ]);
  });


  test('migrated legacy reminder projects exactly once under its existing identity', () {
    final task = Task.fromJson(<String, dynamic>{
      'id': 'legacy-projection',
      'title': 'تماس',
      'reminderDate': '2026-10-13T09:00:00.000',
    });

    final reminders = projection.project(<Task>[task]);
    final legacyEvents = reminders
        .where((item) => item.id == 'task-reminder:legacy-projection')
        .toList();

    expect(legacyEvents, hasLength(1));
    expect(legacyEvents.single.title, 'یادآوری: تماس');
    expect(legacyEvents.single.date, DateTime(2026, 10, 13, 9));
    expect(task.legacyReminderMigrationCompleted, isTrue);
  });

  test('same-time Task reminders remain distinct and preserve all-day state', () {
    final date = DateTime(2026, 10, 13, 0);
    final createdAt = DateTime(2026, 10, 1, 10);
    final task = Task(
      id: 'multi-reminder',
      title: 'کار',
      taskReminders: <TaskReminder>[
        TaskReminder(
          id: 'r1',
          taskId: 'multi-reminder',
          title: 'کار — یادآور ۱',
          date: date,
          status: 'active',
          createdAt: createdAt,
          updatedAt: createdAt,
          isAllDay: true,
          sequence: 1,
        ),
        TaskReminder(
          id: 'r2',
          taskId: 'multi-reminder',
          title: 'کار — یادآور ۲',
          date: date,
          status: 'active',
          createdAt: createdAt,
          updatedAt: createdAt,
          isAllDay: false,
          sequence: 2,
        ),
      ],
      nextReminderSequence: 3,
    );

    final reminders = projection.project(<Task>[task]);

    expect(reminders, hasLength(2));
    expect(reminders.map((item) => item.id).toSet(), {
      'task-reminder-item:multi-reminder:r1',
      'task-reminder-item:multi-reminder:r2',
    });
    expect(
      reminders.singleWhere((item) => item.id == 'task-reminder-item:multi-reminder:r1').isAllDay,
      isTrue,
    );
    expect(
      reminders.singleWhere((item) => item.id == 'task-reminder-item:multi-reminder:r2').isAllDay,
      isFalse,
    );
  });

  test('legacy migration tombstone suppresses the old event after removal', () {
    final task = Task.fromJson(<String, dynamic>{
      'id': 'deleted-legacy-reminder',
      'title': 'کار',
      'reminderDate': '2026-10-13T09:00:00.000',
    });
    task.taskReminders.clear();

    final reminders = projection.project(<Task>[task]);

    expect(task.reminderDate, DateTime(2026, 10, 13, 9));
    expect(task.legacyReminderMigrationCompleted, isTrue);
    expect(
      reminders.any((item) => item.id == 'task-reminder:deleted-legacy-reminder'),
      isFalse,
    );
  });
}
