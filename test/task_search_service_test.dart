import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_search_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = TaskSearchService();

  test('searches title, description, tags, and follow-up text', () {
    final tasks = [
      Task(
        id: '1',
        title: 'تماس با مشتری',
        description: 'ارسال مدارک قرارداد',
        tags: ['مهم'],
        followUps: [
          FollowUp(
            id: 'f1',
            dateTime: DateTime(2026, 8, 14, 10, 30),
            note: 'منتظر پاسخ مدیر',
            result: 'ارسال شد',
          ),
        ],
      ),
      Task(id: '2', title: 'جلسه تیم'),
    ];

    expect(service.search(tasks, 'قرارداد').map((e) => e.id), ['1']);
    expect(service.search(tasks, 'مهم').map((e) => e.id), ['1']);
    expect(service.search(tasks, 'مدیر').map((e) => e.id), ['1']);
    expect(service.search(tasks, 'ارسال شد').map((e) => e.id), ['1']);
  });

  test('is case-insensitive and trims the query', () {
    final tasks = [Task(id: '1', title: 'Important Meeting')];

    expect(service.search(tasks, '  IMPORTANT '), hasLength(1));
  });

  test('matches Persian and Arabic letter variants', () {
    final tasks = [Task(id: '1', title: 'پیگیری یک کار')];

    expect(service.search(tasks, 'پيگيري يك كار').map((e) => e.id), ['1']);
  });

  test('ignores Persian separators and diacritics', () {
    final tasks = [Task(id: '1', title: 'پی‌گیریِ مشتری')];

    expect(service.search(tasks, 'پیگیری مشتری').map((e) => e.id), ['1']);
  });

  test('empty query preserves task order without mutating the input list', () {
    final tasks = [
      Task(id: '1', title: 'اول'),
      Task(id: '2', title: 'دوم'),
    ];

    final result = service.search(tasks, ' ');

    expect(result.map((task) => task.id).toList(), ['1', '2']);
    expect(identical(result, tasks), isFalse);
  });
}
