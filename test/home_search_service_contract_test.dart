import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_search_service.dart';

void main() {
  const service = TaskSearchService();

  test('Home search contract covers Persian variants and follow-up text', () {
    final tasks = <Task>[
      Task(
        id: '1',
        title: 'يادداشت كاری',
        description: 'نمونه',
      ),
      Task(
        id: '2',
        title: 'کار دوم',
        followUps: [
          FollowUp(
            id: 'f-1',
            dateTime: DateTime(2026, 8, 25),
            note: 'تماس با مشتری',
          ),
        ],
      ),
    ];

    expect(service.search(tasks, 'یادداشت کاری').map((e) => e.id), ['1']);
    expect(service.search(tasks, 'مشتری').map((e) => e.id), ['2']);
  });
}
