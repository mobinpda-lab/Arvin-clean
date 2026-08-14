import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/follow_up_repository.dart';
import 'package:arvin/models/task.dart';

void main() {
  test('reads legacy followUpDate without rewriting it', () async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"t1","title":"کار","followUpDate":"2026-08-14T09:30:00.000"}]',
    });

    const repository = FollowUpRepository();
    final followUps = await repository.loadForTask('t1');

    expect(followUps, hasLength(1));
    expect(followUps.single.dateTime, DateTime(2026, 8, 14, 9, 30));
    expect(followUps.single.note, 'مهاجرت خودکار از تاریخ پیگیری قبلی');
  });

  test('appends a FollowUp while preserving the task envelope', () async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"t1","title":"کار","followUpDate":"2026-08-14T09:30:00.000"}]',
    });

    const repository = FollowUpRepository();
    final followUp = FollowUp(
      id: 'f2',
      dateTime: DateTime(2026, 8, 15, 10, 15),
      note: 'تماس مجدد',
      result: 'پاسخ دریافت شد',
      nextFollowUp: DateTime(2026, 8, 20, 10, 15),
    );

    await repository.add('t1', followUp);
    final followUps = await repository.loadForTask('t1');

    expect(followUps, hasLength(2));
    expect(followUps.last.id, 'f2');
    expect(followUps.last.result, 'پاسخ دریافت شد');
  });
}
