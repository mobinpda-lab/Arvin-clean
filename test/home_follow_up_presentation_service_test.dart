import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/home_follow_up_presentation_service.dart';

void main() {
  const service = HomeFollowUpPresentationService();

  test('Home uses chronologically latest real FollowUp and ignores legacy date', () {
    final task = Task(
      id: 'task-1',
      title: 'تماس با علی',
      followUpEnabled: true,
      followUpDate: DateTime(2030, 1, 1, 8),
      followUps: [
        FollowUp(
          id: 'newer',
          dateTime: DateTime(2026, 8, 28, 10, 45),
          note: 'هماهنگی انجام شد',
        ),
        FollowUp(
          id: 'older',
          dateTime: DateTime(2026, 8, 23, 7, 45),
          note: 'منتظر پاسخ',
        ),
      ],
    );

    final value = service.project(
      task,
      now: DateTime(2026, 8, 31, 10, 45),
    );

    expect(value, isNotNull);
    expect(value!.followUpId, 'newer');
    expect(value.title, 'هماهنگی انجام شد');
    expect(value.exactDateTime, '۱۴۰۵/۰۶/۰۶ • ساعت ۱۰:۴۵');
    expect(value.relative, '۳ روز پیش');
    expect(value.dateTime, isNot(task.followUpDate));
  });

  test('Home does not fabricate latest FollowUp when only legacy date exists', () {
    final task = Task(
      id: 'task-2',
      title: 'بدون تاریخچه',
      followUpEnabled: true,
      followUpDate: DateTime(2026, 9, 1, 9),
    );

    expect(service.project(task, now: DateTime(2026, 8, 31)), isNull);
  });

  test('blank FollowUp note presents canonical default title', () {
    final task = Task(
      id: 'task-3',
      title: 'کار',
      followUps: [
        FollowUp(
          id: 'f1',
          dateTime: DateTime(2026, 8, 28, 10, 45),
          note: '',
        ),
      ],
    );

    expect(
      service.project(task, now: DateTime(2026, 8, 28, 11))!.title,
      'پیگیری',
    );
  });
}
