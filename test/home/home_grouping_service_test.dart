import 'package:arvin/home/grouping/home_group_mode.dart';
import 'package:arvin/home/grouping/home_grouping_service.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/iran_clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('time grouping has five buckets and keeps completed past tasks after active overdue tasks', () {
    final now = IranClock.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final future = today.add(const Duration(days: 3));
    final tasks = <Task>[
      Task(id: 'completed-overdue', title: 'گذشته تکمیل‌شده', dueDate: yesterday, completed: true),
      Task(id: 'today', title: 'امروز', dueDate: today),
      Task(id: 'active-overdue', title: 'گذشته فعال', dueDate: yesterday),
      Task(id: 'tomorrow', title: 'فردا', dueDate: tomorrow),
      Task(id: 'future', title: 'آینده', dueDate: future),
      Task(id: 'no-date', title: 'بدون زمان'),
    ];

    final groups = const HomeGroupingService().buildGroups(
      HomeGroupMode.time,
      tasks,
    );

    expect(groups.map((group) => group.id), [
      'overdue',
      'today',
      'tomorrow',
      'future',
      'no_date',
    ]);
    expect(
      groups.first.items.map((task) => task.id),
      ['active-overdue', 'completed-overdue'],
    );
    expect(groups[1].items.map((task) => task.id), ['today']);
    expect(groups[2].items.map((task) => task.id), ['tomorrow']);
    expect(groups[3].items.map((task) => task.id), ['future']);
    expect(groups[4].items.map((task) => task.id), ['no-date']);
  });
}
