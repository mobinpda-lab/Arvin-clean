import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/follow_up.dart';

void main() {
  test('serializes and restores a follow-up without losing time', () {
    final followUp = FollowUp(
      id: 'fu-1',
      dateTime: DateTime(2026, 8, 14, 18, 30),
      description: 'تماس با مشتری',
      result: 'منتظر پاسخ',
      nextFollowUp: DateTime(2026, 8, 16, 10, 15),
    );

    final restored = FollowUp.fromJson(followUp.toJson());

    expect(restored.id, 'fu-1');
    expect(restored.dateTime, followUp.dateTime);
    expect(restored.description, 'تماس با مشتری');
    expect(restored.result, 'منتظر پاسخ');
    expect(restored.nextFollowUp, followUp.nextFollowUp);
  });

  test('allows a follow-up without a scheduled next follow-up', () {
    final followUp = FollowUp(
      id: 'fu-2',
      dateTime: DateTime(2026, 8, 14, 9, 5),
    );

    final restored = FollowUp.fromJson(followUp.toJson());

    expect(restored.nextFollowUp, isNull);
    expect(restored.description, isEmpty);
    expect(restored.result, isEmpty);
  });
}
