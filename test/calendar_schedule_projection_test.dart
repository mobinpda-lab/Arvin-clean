import 'package:arvin/calendar_page.dart';
import 'package:arvin/services/calendar_schedule_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const projection = CalendarScheduleProjection();

  test('projects active timed reminders using the existing 30-minute convention', () {
    final result = projection.project([
      CalendarReminder(
        id: 'followup:task-1:f1',
        title: 'پیگیری',
        date: DateTime(2026, 8, 27, 9),
      ),
    ]);

    expect(result, hasLength(1));
    expect(result.single.ownerId, 'followup:task-1:f1');
    expect(result.single.start, DateTime(2026, 8, 27, 9));
    expect(result.single.end, DateTime(2026, 8, 27, 9, 30));
  });

  test('does not let completed or all-day reminders block clock-time availability', () {
    final result = projection.project([
      CalendarReminder(
        id: 'done',
        title: 'انجام‌شده',
        date: DateTime(2026, 8, 27, 9),
        completed: true,
      ),
      CalendarReminder(
        id: 'holiday',
        title: 'تمام‌روز',
        date: DateTime(2026, 8, 27),
        isAllDay: true,
      ),
      CalendarReminder(
        id: 'active',
        title: 'فعال',
        date: DateTime(2026, 8, 27, 10),
      ),
    ]);

    expect(result.map((item) => item.ownerId).toList(), ['active']);
  });

  test('sorts projected intervals deterministically', () {
    final result = projection.project([
      CalendarReminder(
        id: 'later',
        title: 'بعدی',
        date: DateTime(2026, 8, 27, 11),
      ),
      CalendarReminder(
        id: 'early-b',
        title: 'زود ب',
        date: DateTime(2026, 8, 27, 9),
      ),
      CalendarReminder(
        id: 'early-a',
        title: 'زود الف',
        date: DateTime(2026, 8, 27, 9),
      ),
    ]);

    expect(
      result.map((item) => item.ownerId).toList(),
      ['early-a', 'early-b', 'later'],
    );
  });

  test('allows an explicit duration while rejecting non-positive duration', () {
    const hourProjection = CalendarScheduleProjection(
      timedDuration: Duration(hours: 1),
    );
    final reminder = CalendarReminder(
      id: 'meeting',
      title: 'جلسه',
      date: DateTime(2026, 8, 27, 12),
    );

    expect(
      hourProjection.project([reminder]).single.end,
      DateTime(2026, 8, 27, 13),
    );
    expect(
      () => const CalendarScheduleProjection(
        timedDuration: Duration.zero,
      ).project([reminder]),
      throwsArgumentError,
    );
  });
}
