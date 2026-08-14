import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/services/follow_up_history.dart';

void main() {
  test('latest follow-up is selected by date, not insertion order', () {
    final older = FollowUpHistoryEntry(
      dateTime: DateTime(2026, 8, 10, 9),
      note: 'older',
    );
    final newer = FollowUpHistoryEntry(
      dateTime: DateTime(2026, 8, 13, 15, 30),
      note: 'newer',
    );

    expect(FollowUpHistory.latest([newer, older])?.note, 'newer');
    expect(FollowUpHistory.latest([older, newer])?.note, 'newer');
  });

  test('ordered returns newest first', () {
    final entries = [
      FollowUpHistoryEntry(dateTime: DateTime(2026, 8, 12)),
      FollowUpHistoryEntry(dateTime: DateTime(2026, 8, 14)),
      FollowUpHistoryEntry(dateTime: DateTime(2026, 8, 13)),
    ];

    final result = FollowUpHistory.ordered(entries);
    expect(result.map((e) => e.dateTime.day), [14, 13, 12]);
  });

  test('legacy follow-up date migrates to one history entry', () {
    final date = DateTime(2026, 8, 14, 10, 45);
    final result = FollowUpHistory.migrateLegacyDate(date);

    expect(result, hasLength(1));
    expect(result.single.dateTime, date);
  });

  test('null legacy date does not create a fake follow-up', () {
    expect(FollowUpHistory.migrateLegacyDate(null), isEmpty);
  });
}
