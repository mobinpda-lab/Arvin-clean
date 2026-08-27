import 'package:arvin/services/rescheduling_planner.dart';
import 'package:arvin/services/schedule_conflict_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const planner = ReschedulingPlanner();

  ScheduleInterval busy(String id, int startHour, int startMinute, int endHour, int endMinute) {
    return ScheduleInterval(
      id: id,
      start: DateTime(2026, 8, 27, startHour, startMinute),
      end: DateTime(2026, 8, 27, endHour, endMinute),
    );
  }

  test('returns earliest conflict-free suggestions in deterministic order', () {
    final result = planner.suggest(
      busy: [busy('meeting', 9, 0, 10, 0)],
      windowStart: DateTime(2026, 8, 27, 9),
      windowEnd: DateTime(2026, 8, 27, 12),
      duration: const Duration(minutes: 30),
      step: const Duration(minutes: 30),
      limit: 3,
    );

    expect(
      result.map((item) => item.start).toList(),
      [
        DateTime(2026, 8, 27, 10),
        DateTime(2026, 8, 27, 10, 30),
        DateTime(2026, 8, 27, 11),
      ],
    );
  });

  test('allows a suggestion that starts exactly when busy time ends', () {
    final result = planner.suggest(
      busy: [busy('meeting', 9, 0, 10, 0)],
      windowStart: DateTime(2026, 8, 27, 9, 45),
      windowEnd: DateTime(2026, 8, 27, 10, 30),
      duration: const Duration(minutes: 30),
      step: const Duration(minutes: 15),
      limit: 1,
    );

    expect(result.single.start, DateTime(2026, 8, 27, 10));
    expect(result.single.end, DateTime(2026, 8, 27, 10, 30));
  });

  test('candidate identity is independent from caller-provided interval ids', () {
    final result = planner.suggest(
      busy: [
        busy('__reschedule_candidate__1', 8, 0, 9, 0),
        busy('overlapping-busy', 8, 30, 8, 45),
      ],
      windowStart: DateTime(2026, 8, 27, 10),
      windowEnd: DateTime(2026, 8, 27, 10, 30),
      duration: const Duration(minutes: 30),
      limit: 1,
    );

    expect(result, hasLength(1));
    expect(result.single.start, DateTime(2026, 8, 27, 10));
  });

  test('returns empty when no candidate fits the requested window', () {
    final result = planner.suggest(
      busy: [busy('meeting', 9, 0, 11, 0)],
      windowStart: DateTime(2026, 8, 27, 9),
      windowEnd: DateTime(2026, 8, 27, 11),
      duration: const Duration(hours: 1),
      step: const Duration(minutes: 30),
    );

    expect(result, isEmpty);
  });

  test('rejects invalid duration, step, window, and limit', () {
    expect(
      () => planner.suggest(
        busy: const [],
        windowStart: DateTime(2026, 8, 27, 10),
        windowEnd: DateTime(2026, 8, 27, 9),
        duration: const Duration(minutes: 30),
      ),
      throwsArgumentError,
    );
    expect(
      () => planner.suggest(
        busy: const [],
        windowStart: DateTime(2026, 8, 27, 9),
        windowEnd: DateTime(2026, 8, 27, 10),
        duration: Duration.zero,
      ),
      throwsArgumentError,
    );
    expect(
      () => planner.suggest(
        busy: const [],
        windowStart: DateTime(2026, 8, 27, 9),
        windowEnd: DateTime(2026, 8, 27, 10),
        duration: const Duration(minutes: 30),
        step: Duration.zero,
      ),
      throwsArgumentError,
    );
    expect(
      () => planner.suggest(
        busy: const [],
        windowStart: DateTime(2026, 8, 27, 9),
        windowEnd: DateTime(2026, 8, 27, 10),
        duration: const Duration(minutes: 30),
        limit: 0,
      ),
      throwsArgumentError,
    );
  });
}
