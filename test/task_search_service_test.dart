import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_search_service.dart';

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

  test('empty query preserves task order', () {
    final tasks = [
      Task(id: '1', title: 'اول'),
      Task(id: '2', title: 'دوم'),
    ];

    expect(service.search(tasks, ' '), same(tasks));
  });
}
