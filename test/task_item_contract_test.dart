import 'package:flutter_test/flutter_test.dart';
import 'package:arvin_clean/models/task.dart';

void main() {
  group('unified Item contract', () {
    test('a new item behaves as a simple note', () {
      final task = Task(id: '1', title: 'یادداشت');

      expect(task.isSimpleNote, isTrue);
      expect(task.followUpEnabled, isFalse);
      expect(task.followUps, isEmpty);
    });

    test('enabling follow-up changes the same item into a follow-up item', () {
      final task = Task(id: '1', title: 'تماس');
      task.followUpEnabled = true;
      task.followUps = [
        FollowUp(
          id: 'f1',
          dateTime: DateTime(2026, 8, 15, 10, 30),
          note: 'تماس انجام شد',
        ),
      ];

      expect(task.isSimpleNote, isFalse);
      expect(task.followUps, hasLength(1));
      expect(task.lastFollowUp?.note, 'تماس انجام شد');
      expect(task.lastFollowUpDate, DateTime(2026, 8, 15, 10, 30));
    });

    test('legacy follow-up date migrates without creating a second item', () {
      final task = Task.fromJson({
        'id': 'legacy-1',
        'title': 'کار قدیمی',
        'followUpDate': '2026-08-15T09:00:00.000',
      });

      expect(task.id, 'legacy-1');
      expect(task.followUpEnabled, isTrue);
      expect(task.followUps, hasLength(1));
      expect(task.isSimpleNote, isFalse);
    });
  });
}
