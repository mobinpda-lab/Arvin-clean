import 'package:arvin/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preserves the legacy Home follow-up date when history is absent', () {
    final date = DateTime(2026, 8, 25, 9);
    final task = Task(id: 'legacy-date', title: 'پیگیری', followUpDate: date);

    expect(task.legacyHomeFollowUpDate, date);
  });

  test('uses the latest follow-up for the Home view when history exists', () {
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

    expect(task.legacyHomeFollowUpDate, later);
    expect(task.lastFollowUpDate, later);
  });

  test('latest follow-up is based on date rather than list order', () {
    final earlier = DateTime(2026, 8, 25, 9);
    final latest = DateTime(2026, 8, 29, 14, 30);
    final middle = DateTime(2026, 8, 27, 11);
    final task = Task(
      id: 'unordered-history',
      title: 'پیگیری نامرتب',
      followUps: [
        FollowUp(id: 'latest', dateTime: latest),
        FollowUp(id: 'earlier', dateTime: earlier),
        FollowUp(id: 'middle', dateTime: middle),
      ],
    );

    expect(task.lastFollowUp?.id, 'latest');
    expect(task.lastFollowUpDate, latest);
    expect(task.legacyHomeFollowUpDate, latest);
  });
}
