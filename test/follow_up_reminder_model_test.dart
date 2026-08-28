import 'package:arvin/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FollowUp reminder is optional and survives canonical JSON round-trip', () {
    final followUp = FollowUp(
      id: 'f-reminder',
      dateTime: DateTime(2026, 8, 28, 15, 30),
      note: 'تماس با مشتری',
      result: 'منتظر پاسخ',
      reminderDate: DateTime(2026, 8, 28, 15, 15),
      nextFollowUp: DateTime(2026, 8, 30, 10),
    );

    final restored = FollowUp.fromJson(followUp.toJson());

    expect(restored.id, followUp.id);
    expect(restored.dateTime, followUp.dateTime);
    expect(restored.note, followUp.note);
    expect(restored.result, followUp.result);
    expect(restored.reminderDate, followUp.reminderDate);
    expect(restored.nextFollowUp, followUp.nextFollowUp);
  });

  test('legacy FollowUp JSON without reminder remains valid', () {
    final restored = FollowUp.fromJson({
      'id': 'legacy',
      'dateTime': '2026-08-28T10:00:00.000',
      'note': 'پیگیری قبلی',
      'result': null,
      'nextFollowUp': null,
    });

    expect(restored.reminderDate, isNull);
    expect(restored.note, 'پیگیری قبلی');
  });

  test('Task envelope preserves FollowUp reminder without a second store', () {
    final task = Task(
      id: 't1',
      title: 'قرارداد',
      followUpEnabled: true,
      followUps: [
        FollowUp(
          id: 'f1',
          dateTime: DateTime(2026, 8, 28, 12),
          reminderDate: DateTime(2026, 8, 28, 11, 45),
        ),
      ],
    );

    final restored = Task.fromJson(task.toJson());

    expect(restored.followUps, hasLength(1));
    expect(
      restored.followUps.single.reminderDate,
      DateTime(2026, 8, 28, 11, 45),
    );
  });
}
