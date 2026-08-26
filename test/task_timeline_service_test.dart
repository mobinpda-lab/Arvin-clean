import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_timeline_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = TaskTimelineService();

  test('builds a chronological timeline from canonical task timestamps', () {
    final task = Task(
      id: 'task-1',
      title: 'پرونده مشتری',
      createdAt: DateTime(2026, 8, 26, 8),
      reminderDate: DateTime(2026, 8, 26, 12),
      updatedAt: DateTime(2026, 8, 26, 15),
      followUps: [
        FollowUp(
          id: 'late',
          dateTime: DateTime(2026, 8, 26, 14),
          note: 'پیگیری دوم',
        ),
        FollowUp(
          id: 'early',
          dateTime: DateTime(2026, 8, 26, 10),
          note: 'پیگیری اول',
        ),
      ],
    );

    final timeline = service.build(task);

    expect(
      timeline.map((entry) => entry.kind).toList(),
      [
        TaskTimelineEntryKind.created,
        TaskTimelineEntryKind.followUp,
        TaskTimelineEntryKind.reminder,
        TaskTimelineEntryKind.followUp,
        TaskTimelineEntryKind.updated,
      ],
    );
    expect(
      timeline.map((entry) => entry.dateTime.hour).toList(),
      [8, 10, 12, 14, 15],
    );
  });

  test('preserves stable follow-up ids, notes, and results', () {
    final task = Task(
      id: 'task-2',
      title: 'فروش',
      followUps: [
        FollowUp(
          id: 'followup-42',
          dateTime: DateTime(2026, 8, 26, 11, 30),
          note: 'تماس با مشتری',
          result: 'پاسخ مثبت',
        ),
      ],
    );

    final entry = service.build(task).single;

    expect(entry.id, 'followup:followup-42');
    expect(entry.kind, TaskTimelineEntryKind.followUp);
    expect(entry.note, 'تماس با مشتری');
    expect(entry.result, 'پاسخ مثبت');
  });

  test('uses legacy followUpDate only when canonical history is empty', () {
    final legacyOnly = Task(
      id: 'legacy',
      title: 'قدیمی',
      followUpDate: DateTime(2026, 8, 27, 9),
    );
    final withHistory = Task(
      id: 'canonical',
      title: 'جدید',
      followUpDate: DateTime(2026, 8, 27, 9),
      followUps: [
        FollowUp(
          id: 'real',
          dateTime: DateTime(2026, 8, 28, 10),
        ),
      ],
    );

    final legacyTimeline = service.build(legacyOnly);
    final canonicalTimeline = service.build(withHistory);

    expect(legacyTimeline, hasLength(1));
    expect(legacyTimeline.single.id, 'task:legacy:legacy-followup');
    expect(canonicalTimeline, hasLength(1));
    expect(canonicalTimeline.single.id, 'followup:real');
  });

  test('orders equal timestamps deterministically', () {
    final sameTime = DateTime(2026, 8, 26, 12);
    final task = Task(
      id: 'same-time',
      title: 'هم‌زمان',
      createdAt: sameTime,
      reminderDate: sameTime,
      updatedAt: sameTime,
      followUps: [
        FollowUp(id: 'b', dateTime: sameTime),
        FollowUp(id: 'a', dateTime: sameTime),
      ],
    );

    expect(
      service.build(task).map((entry) => entry.id).toList(),
      [
        'task:same-time:created',
        'task:same-time:reminder',
        'followup:a',
        'followup:b',
        'task:same-time:updated',
      ],
    );
  });
}
