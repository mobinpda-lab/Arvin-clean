import 'package:arvin/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preserves the legacy Home follow-up date when history is absent', () {
    final date = DateTime(2026, 8, 25, 9);
    final task = Task(id: 'legacy-date', title: 'پیگیری', followUpDate: date);

    expect(task.legacyHomeFollowUpDate, date);
  });

  test('uses the latest FollowUp next-action date for the Home view', () {
    final first = DateTime(2026, 8, 25, 9);
    final later = DateTime(2026, 8, 27, 9);
    final firstNextAction = DateTime(2026, 8, 26, 10);
    final laterNextAction = DateTime(2026, 8, 30, 10);
    final task = Task(
      id: 'history-date',
      title: 'پیگیری',
      followUpDate: DateTime(2026, 8, 20),
      followUps: [
        FollowUp(
          id: 'first',
          dateTime: first,
          nextFollowUp: firstNextAction,
        ),
        FollowUp(
          id: 'later',
          dateTime: later,
          nextFollowUp: laterNextAction,
        ),
      ],
    );

    expect(task.legacyHomeFollowUpDate, laterNextAction);
    expect(task.lastFollowUpDate, later);
  });

  test('latest FollowUp record is based on action date rather than list order', () {
    final earlier = DateTime(2026, 8, 25, 9);
    final latest = DateTime(2026, 8, 29, 14, 30);
    final middle = DateTime(2026, 8, 27, 11);
    final latestNextAction = DateTime(2026, 8, 31, 9);
    final task = Task(
      id: 'unordered-history',
      title: 'پیگیری نامرتب',
      followUps: [
        FollowUp(
          id: 'latest',
          dateTime: latest,
          nextFollowUp: latestNextAction,
        ),
        FollowUp(
          id: 'earlier',
          dateTime: earlier,
          nextFollowUp: DateTime(2026, 8, 26, 9),
        ),
        FollowUp(
          id: 'middle',
          dateTime: middle,
          nextFollowUp: DateTime(2026, 8, 28, 9),
        ),
      ],
    );

    expect(task.lastFollowUp?.id, 'latest');
    expect(task.lastFollowUpDate, latest);
    expect(task.legacyHomeFollowUpDate, latestNextAction);
  });
}
