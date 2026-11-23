import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';

void main() {
  test('legacy task JSON preserves scheduling data without fake history', () {
    final legacyDate = DateTime.parse('2026-08-20T09:30:00.000');
    final task = Task.fromJson({
      'id': 'legacy-1',
      'title': 'کار قدیمی',
      'description': 'اطلاعات قدیمی',
      'followUpDate': legacyDate.toIso8601String(),
      'tags': ['قدیمی'],
      'archived': false,
      'trashed': false,
      'completed': false,
    });

    expect(task.id, 'legacy-1');
    expect(task.title, 'کار قدیمی');
    expect(task.description, 'اطلاعات قدیمی');
    expect(task.tags, ['قدیمی']);
    expect(task.followUpEnabled, isTrue);
    expect(task.followUpDate, legacyDate);
    expect(task.followUps, isEmpty);
    expect(task.lastFollowUp, isNull);
  });

  test('Unified Task JSON preserves reminder and recurrence fields', () {
    final task = Task.fromJson({
      'id': 'unified-1',
      'title': 'کار جدید',
      'reminderDate': '2026-08-21T10:00:00.000',
      'followUps': [
        {
          'id': 'f1',
          'dateTime': '2026-08-21T11:00:00.000',
          'note': 'پیگیری',
        },
      ],
    });

    expect(task.reminderDate, DateTime.parse('2026-08-21T10:00:00.000'));
    expect(task.followUps.single.note, 'پیگیری');
    expect(task.toJson()['reminderDate'], '2026-08-21T10:00:00.000');
  });
}
