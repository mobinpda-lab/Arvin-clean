import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/follow_up.dart';
import 'package:arvin/services/follow_up_presentation.dart';

void main() {
  test('presents latest follow-up date, time and note', () {
    final history = [
      FollowUp(id: '1', dateTime: DateTime(2026, 8, 10, 9, 15), note: 'قدیمی'),
      FollowUp(id: '2', dateTime: DateTime(2026, 8, 12, 14, 30), note: 'آخرین تماس'),
    ];

    final result = const FollowUpPresentationService().fromHistory(history);

    expect(result.date, '2026/08/12');
    expect(result.time, '14:30');
    expect(result.note, 'آخرین تماس');
  });

  test('returns empty presentation for empty history', () {
    final result = const FollowUpPresentationService().fromHistory(const []);
    expect(result.isEmpty, isTrue);
  });
}
