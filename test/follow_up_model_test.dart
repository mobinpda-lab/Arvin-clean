import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/follow_up.dart';
import 'package:arvin/models/task.dart';

void main() {
  test('lastFollowUp returns the newest follow-up regardless of list order', () {
    final older = FollowUp(
      id: 'old',
      dateTime: DateTime(2026, 8, 10, 9, 0),
      note: 'قدیمی',
    );
    final newer = FollowUp(
      id: 'new',
      dateTime: DateTime(2026, 8, 13, 14, 30),
      note: 'جدید',
    );

    final task = ArvinTask(
      id: 'task-1',
      title: 'کار آزمایشی',
      followUps: [newer, older],
    );

    expect(task.lastFollowUp?.id, 'new');
    expect(task.lastFollowUpDate, newer.dateTime);
  });

  test('legacy followUpDate is migrated into follow-up history', () {
    final legacyDate = DateTime(2026, 8, 12, 11, 45);
    final task = ArvinTask.fromJson({
      'id': 'legacy-task',
      'title': 'کار قدیمی',
      'followUpDate': legacyDate.toIso8601String(),
    });

    expect(task.followUps, hasLength(1));
    expect(task.lastFollowUpDate, legacyDate);
  });

  test('addFollowUp keeps the legacy date synchronized', () {
    final task = ArvinTask(id: 'task-2', title: 'کار');
    final followUp = FollowUp(
      id: 'f1',
      dateTime: DateTime(2026, 8, 14, 16, 20),
    );

    task.addFollowUp(followUp);

    expect(task.followUps, hasLength(1));
    expect(task.followUpDate, followUp.dateTime);
  });
}
