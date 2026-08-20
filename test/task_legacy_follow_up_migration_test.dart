import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';

void main() {
  test('legacy followUpDate is migrated into followUps', () {
    final task = Task.fromJson({
      'id': 'legacy-1',
      'title': 'Legacy reminder',
      'followUpDate': '2026-08-18T09:30:00.000',
    });

    expect(task.followUps, hasLength(1));
    expect(task.followUps.single.dateTime, DateTime(2026, 8, 18, 9, 30));
    expect(task.followUps.single.note, contains('مهاجرت'));
    expect(task.followUpEnabled, isTrue);
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
  });
}
