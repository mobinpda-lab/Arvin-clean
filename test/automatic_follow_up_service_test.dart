import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/automatic_follow_up_service.dart';

void main() {
  const service = AutomaticFollowUpService();
  final now = DateTime(2026, 8, 26, 14);

  test('legacy nextFollowUp never becomes an automatic delivery candidate', () {
    final task = Task(
      id: 'legacy',
      title: 'سابقه قدیمی',
      followUps: [
        FollowUp(
          id: 'f1',
          dateTime: DateTime(2026, 8, 25, 9),
          nextFollowUp: now.subtract(const Duration(minutes: 1)),
        ),
      ],
    );

    expect(service.scheduledCandidates([task]), isEmpty);
    expect(service.dueCandidates([task], now: now), isEmpty);
  });

  test('legacy Task followUpDate does not create an automatic candidate', () {
    final task = Task(
      id: 'legacy-task-date',
      title: 'سابقه قدیمی',
      followUpDate: now.subtract(const Duration(days: 1)),
    );
    expect(service.scheduledCandidates([task]), isEmpty);
    expect(service.dueCandidates([task], now: now), isEmpty);
  });
}
