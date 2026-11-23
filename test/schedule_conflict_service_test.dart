import 'package:arvin/services/schedule_conflict_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = ScheduleConflictService();

  ScheduleInterval slot(
    String id,
    int startHour,
    int startMinute,
    int endHour,
    int endMinute,
  ) {
    return ScheduleInterval(
      id: id,
      start: DateTime(2026, 8, 27, startHour, startMinute),
      end: DateTime(2026, 8, 27, endHour, endMinute),
    );
  }

  test('detects overlapping intervals with exact overlap bounds', () {
    final result = service.findConflicts([
      slot('a', 9, 0, 10, 0),
      slot('b', 9, 30, 10, 30),
    ]);

    expect(result, hasLength(1));
    expect(result.single.first.id, 'a');
    expect(result.single.second.id, 'b');
    expect(result.single.overlapStart, DateTime(2026, 8, 27, 9, 30));
    expect(result.single.overlapEnd, DateTime(2026, 8, 27, 10));
    expect(result.single.overlap, const Duration(minutes: 30));
  });

  test('treats touching boundaries as non-conflicting', () {
    final result = service.findConflicts([
      slot('a', 9, 0, 10, 0),
      slot('b', 10, 0, 11, 0),
    ]);

    expect(result, isEmpty);
  });

  test('finds nested and chained conflicts deterministically', () {
    final result = service.findConflicts([
      slot('c', 9, 45, 10, 15),
      slot('a', 9, 0, 11, 0),
      slot('b', 9, 30, 10, 0),
      slot('d', 11, 0, 12, 0),
    ]);

    expect(
      result.map((item) => '${item.first.id}-${item.second.id}').toList(),
      ['a-b', 'a-c', 'b-c'],
    );
  });

  test('rejects zero or negative length intervals', () {
    expect(
      () => ScheduleInterval(
        id: 'invalid',
        start: DateTime(2026, 8, 27, 9),
        end: DateTime(2026, 8, 27, 9),
      ),
      throwsArgumentError,
    );
  });
}
