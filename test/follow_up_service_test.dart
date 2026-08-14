import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_service.dart';

void main() {
  test('returns latest follow-up by date', () async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"t1","title":"کار","followUps":[{"id":"old","dateTime":"2026-08-10T09:00:00.000","note":"قدیمی"},{"id":"new","dateTime":"2026-08-14T09:00:00.000","note":"جدید"}]}]',
    });

    final service = FollowUpService();
    final latest = await service.latestForTask('t1');

    expect(latest?.id, 'new');
  });

  test('returns the earliest future next-follow-up', () async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"t1","title":"کار","followUps":[{"id":"a","dateTime":"2026-08-10T09:00:00.000","nextFollowUp":"2026-08-20T09:00:00.000"},{"id":"b","dateTime":"2026-08-11T09:00:00.000","nextFollowUp":"2026-08-16T09:00:00.000"}]}]',
    });

    final service = FollowUpService();
    final next = await service.nextForTask(
      't1',
      now: DateTime(2026, 8, 14, 12),
    );

    expect(next?.id, 'b');
  });

  test('returns null when there is no future follow-up', () async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"t1","title":"کار","followUps":[{"id":"a","dateTime":"2026-08-10T09:00:00.000","nextFollowUp":"2026-08-12T09:00:00.000"}]}]',
    });

    final service = FollowUpService();
    final next = await service.nextForTask(
      't1',
      now: DateTime(2026, 8, 14),
    );

    expect(next, isNull);
  });

  test('can append a follow-up through the application service', () async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"t1","title":"کار"}]',
    });

    final service = FollowUpService();
    await service.addToTask(
      't1',
      const FollowUp(
        id: 'f1',
        dateTime: DateTime(2026, 8, 14, 10),
        note: 'تماس',
      ),
    );

    final items = await service.loadForTask('t1');
    expect(items, hasLength(1));
    expect(items.single.id, 'f1');
  });
}
