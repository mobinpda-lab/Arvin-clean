import 'package:arvin/models/task.dart';
import 'package:arvin/services/home_today_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const projection = HomeTodayProjection();
  final today = DateTime(2026, 8, 27, 12);

  Task task(
    String id,
    DateTime? followUpDate, {
    bool completed = false,
    bool archived = false,
    bool trashed = false,
  }) {
    return Task(
      id: id,
      title: id,
      followUpEnabled: followUpDate != null,
      followUpDate: followUpDate,
      completed: completed,
      archived: archived,
      trashed: trashed,
    );
  }

  test('selects only open canonical tasks scheduled for the local day', () {
    final result = projection.select(
      [
        task('today', DateTime(2026, 8, 27, 8)),
        task('tomorrow', DateTime(2026, 8, 28, 8)),
        task('unscheduled', null),
        task('completed', DateTime(2026, 8, 27, 9), completed: true),
        task('archived', DateTime(2026, 8, 27, 10), archived: true),
        task('trashed', DateTime(2026, 8, 27, 11), trashed: true),
      ],
      now: today,
    );

    expect(result.map((item) => item.id), ['today']);
  });

  test('uses latest canonical FollowUp history instead of stale legacy date', () {
    final item = task('history', DateTime(2026, 8, 27, 8));
    item.followUps = [
      FollowUp(
        id: 'old',
        dateTime: DateTime(2026, 8, 27, 8),
        note: 'old',
      ),
      FollowUp(
        id: 'latest',
        dateTime: DateTime(2026, 8, 28, 8),
        note: 'latest',
      ),
    ];

    expect(projection.select([item], now: today), isEmpty);
  });

  test('does not mutate or reorder the source list', () {
    final source = [
      task('second', DateTime(2026, 8, 27, 14)),
      task('first', DateTime(2026, 8, 27, 9)),
    ];

    final result = projection.select(source, now: today);

    expect(result.map((item) => item.id), ['second', 'first']);
    expect(source.map((item) => item.id), ['second', 'first']);
  });
}
