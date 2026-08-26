import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/automatic_follow_up_service.dart';

void main() {
  const service = AutomaticFollowUpService();
  final now = DateTime(2026, 8, 26, 14);

  FollowUp followUp(
    String id,
    DateTime occurredAt, {
    DateTime? nextFollowUp,
  }) {
    return FollowUp(
      id: id,
      dateTime: occurredAt,
      nextFollowUp: nextFollowUp,
    );
  }

  test('returns due latest follow-up including exact-now schedules', () {
    final task = Task(
      id: 'due',
      title: 'تماس مشتری',
      followUps: [
        followUp(
          'latest',
          DateTime(2026, 8, 25, 9),
          nextFollowUp: now,
        ),
      ],
    );

    final result = service.dueCandidates([task], now: now);

    expect(result, hasLength(1));
    expect(result.single.taskId, 'due');
    expect(result.single.followUpId, 'latest');
    expect(result.single.dueAt, now);
  });

  test('does not return future schedules', () {
    final task = Task(
      id: 'future',
      title: 'آینده',
      followUps: [
        followUp(
          'future-followup',
          DateTime(2026, 8, 25, 9),
          nextFollowUp: now.add(const Duration(minutes: 1)),
        ),
      ],
    );

    expect(service.dueCandidates([task], now: now), isEmpty);
  });

  test('newer follow-up without next schedule supersedes older schedule', () {
    final task = Task(
      id: 'superseded',
      title: 'جایگزین‌شده',
      followUps: [
        followUp(
          'older',
          DateTime(2026, 8, 20),
          nextFollowUp: DateTime(2026, 8, 25),
        ),
        followUp('newer', DateTime(2026, 8, 26, 10)),
      ],
    );

    expect(service.dueCandidates([task], now: now), isEmpty);
  });

  test('uses chronological latest entry when history order is unordered', () {
    final task = Task(
      id: 'unordered',
      title: 'نامرتب',
      followUps: [
        followUp(
          'latest',
          DateTime(2026, 8, 26, 12),
          nextFollowUp: DateTime(2026, 8, 26, 13),
        ),
        followUp(
          'earlier',
          DateTime(2026, 8, 24),
          nextFollowUp: DateTime(2026, 8, 24, 12),
        ),
        followUp('middle', DateTime(2026, 8, 25)),
      ],
    );

    final result = service.dueCandidates([task], now: now);

    expect(result, hasLength(1));
    expect(result.single.followUpId, 'latest');
  });

  test('ignores completed archived and trashed tasks', () {
    Task inactive(String id, {bool completed = false, bool archived = false, bool trashed = false}) {
      return Task(
        id: id,
        title: id,
        completed: completed,
        archived: archived,
        trashed: trashed,
        followUps: [
          followUp(
            '$id-followup',
            DateTime(2026, 8, 25),
            nextFollowUp: DateTime(2026, 8, 26, 13),
          ),
        ],
      );
    }

    final result = service.dueCandidates(
      [
        inactive('completed', completed: true),
        inactive('archived', archived: true),
        inactive('trashed', trashed: true),
      ],
      now: now,
    );

    expect(result, isEmpty);
  });

  test('returns candidates ordered by due time then task id', () {
    Task dueTask(String id, DateTime dueAt) {
      return Task(
        id: id,
        title: id,
        followUps: [
          followUp(
            '$id-followup',
            DateTime(2026, 8, 25),
            nextFollowUp: dueAt,
          ),
        ],
      );
    }

    final result = service.dueCandidates(
      [
        dueTask('b', DateTime(2026, 8, 26, 13)),
        dueTask('c', DateTime(2026, 8, 26, 12)),
        dueTask('a', DateTime(2026, 8, 26, 13)),
      ],
      now: now,
    );

    expect(result.map((item) => item.taskId), ['c', 'a', 'b']);
  });
}
