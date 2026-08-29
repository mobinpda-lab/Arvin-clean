import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/task.dart';

void main() {
  test('supports a date-only FollowUp without requiring a time', () {
    final followUp = FollowUp(
      id: 'all-day-1',
      dateTime: DateTime(2026, 8, 24),
      allDay: true,
      note: 'پیگیری در طول روز',
    );

    final decoded = FollowUp.fromJson(followUp.toJson());

    expect(decoded.allDay, isTrue);
    expect(decoded.dateTime, DateTime(2026, 8, 24));
    expect(decoded.note, 'پیگیری در طول روز');
  });

  test('keeps legacy FollowUp JSON time-aware by default', () {
    final decoded = FollowUp.fromJson({
      'id': 'legacy-1',
      'dateTime': '2026-08-24T10:30:00.000',
      'note': 'پیگیری قدیمی',
    });

    expect(decoded.allDay, isFalse);
    expect(decoded.dateTime, DateTime(2026, 8, 24, 10, 30));
  });
}
