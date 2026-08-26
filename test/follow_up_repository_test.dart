import 'dart:convert';

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

  test('updates one FollowUp without changing siblings or task envelope',
      () async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {
          'id': 't1',
          'title': 'کار',
          'category': 'فروش',
          'followUps': [
            {
              'id': 'f1',
              'dateTime': '2026-08-15T10:15:00.000',
              'note': 'تماس اول',
              'result': null,
              'nextFollowUp': null,
            },
            {
              'id': 'f2',
              'dateTime': '2026-08-20T11:00:00.000',
              'note': 'تماس دوم',
              'result': 'منتظر پاسخ',
              'nextFollowUp': null,
            },
          ],
        },
      ]),
    });

    const repository = FollowUpRepository();
    final edited = FollowUp(
      id: 'f1',
      dateTime: DateTime(2026, 8, 16, 9, 45),
      note: 'تماس اول ویرایش شد',
      result: 'پاسخ دریافت شد',
      nextFollowUp: DateTime(2026, 8, 18, 9, 45),
    );

    await repository.update('t1', edited);

    final followUps = await repository.loadForTask('t1');
    expect(followUps, hasLength(2));
    expect(followUps.first.id, 'f1');
    expect(followUps.first.note, 'تماس اول ویرایش شد');
    expect(followUps.first.result, 'پاسخ دریافت شد');
    expect(followUps.last.id, 'f2');
    expect(followUps.last.note, 'تماس دوم');

    final prefs = await SharedPreferences.getInstance();
    final stored = jsonDecode(prefs.getString('arvin.tasks')!) as List<dynamic>;
    final task = Map<String, dynamic>.from(stored.single as Map);
    expect(task['title'], 'کار');
    expect(task['category'], 'فروش');
  });

  test('update fails when the FollowUp id does not exist', () async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {
          'id': 't1',
          'title': 'کار',
          'followUps': [
            {
              'id': 'f1',
              'dateTime': '2026-08-15T10:15:00.000',
              'note': 'تماس',
              'result': null,
              'nextFollowUp': null,
            },
          ],
        },
      ]),
    });

    const repository = FollowUpRepository();
    final missing = FollowUp(
      id: 'missing',
      dateTime: DateTime(2026, 8, 16, 9),
    );

    expect(
      () => repository.update('t1', missing),
      throwsA(isA<StateError>()),
    );
  });
}
