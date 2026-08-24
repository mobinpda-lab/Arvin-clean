import 'package:arvin/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preserves the legacy Home follow-up date when history is absent', () {
    final date = DateTime(2026, 8, 25, 9);
    final task = Task(id: 'legacy-date', title: 'پیگیری', followUpDate: date);

    expect(task.legacyHomeFollowUpDate, date);
  });

  test('uses the first follow-up to preserve the current Home view behavior', () {
    final first = DateTime(2026, 8, 25, 9);
    final later = DateTime(2026, 8, 27, 9);
    final task = Task(
      id: 'history-date',
      title: 'پیگیری',
      followUpDate: DateTime(2026, 8, 20),
      followUps: [
        FollowUp(id: 'first', dateTime: first),
        FollowUp(id: 'later', dateTime: later),
      ],
    );

    expect(task.legacyHomeFollowUpDate, first);
    expect(task.lastFollowUpDate, later);
  });
}
