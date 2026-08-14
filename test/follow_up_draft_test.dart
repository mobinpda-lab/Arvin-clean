import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/follow_up_draft.dart';

void main() {
  test('creates a follow-up with the supplied system timestamp', () {
    final now = DateTime(2026, 8, 14, 9, 30);
    final followUp = FollowUpDraft.create(now: now);

    expect(followUp.dateTime, now);
    expect(followUp.nextFollowUp, isNull);
  });

  test('date and time can be edited without changing follow-up identity', () {
    final source = FollowUpDraft.create(now: DateTime(2026, 8, 14, 9, 30));
    final edited = FollowUpDraft.updateDateTime(
      source,
      DateTime(2026, 8, 13, 16, 45),
    );

    expect(edited.id, source.id);
    expect(edited.dateTime, DateTime(2026, 8, 13, 16, 45));
  });

  test('next follow-up remains independent from recorded timestamp', () {
    final source = FollowUpDraft.create(now: DateTime(2026, 8, 14, 9, 30));
    final next = DateTime(2026, 8, 20, 14, 0);
    final edited = FollowUpDraft.updateNextFollowUp(source, next);

    expect(edited.dateTime, source.dateTime);
    expect(edited.nextFollowUp, next);
  });
}
