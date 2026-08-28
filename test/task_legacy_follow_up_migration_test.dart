import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';

void main() {
  test('legacy followUpDate remains scheduling data, not fabricated history', () {
    final task = Task.fromJson({
      'id': 'legacy-1',
      'title': 'Legacy reminder',
      'followUpDate': '2026-08-18T09:30:00.000',
    });

    expect(task.followUps, isEmpty);
    expect(task.followUpDate, DateTime(2026, 8, 18, 9, 30));
    expect(task.followUpEnabled, isTrue);
    expect(task.lastFollowUp, isNull);
    expect(task.legacyHomeFollowUpDate, DateTime(2026, 8, 18, 9, 30));
  });

  test('current followUps remain authoritative when legacy date is also present', () {
    final task = Task.fromJson({
      'id': 'current-1',
      'title': 'Current reminder',
      'followUpDate': '2026-08-18T09:30:00.000',
      'followUps': [
        {
          'id': 'fu-1',
          'dateTime': '2026-08-19T10:00:00.000',
          'note': 'Current follow-up',
        },
      ],
    });

    expect(task.followUps, hasLength(1));
    expect(task.followUps.single.id, 'fu-1');
    expect(task.followUps.single.dateTime, DateTime(2026, 8, 19, 10));
    expect(task.lastFollowUp?.id, 'fu-1');
  });
}
