import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/home_today_projection.dart';
import 'package:arvin/services/prayer_completion_projection.dart';
import 'package:arvin/services/prayer_completion_store.dart';
import 'package:arvin/services/task_due_scope_service.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('prayer state never changes canonical Task storage or Task counters', () async {
    final now = DateTime(2026, 9, 15, 12);
    final tasks = <Task>[
      Task(id: 'today-open', title: 'کار امروز', dueDate: DateTime(2026, 9, 15, 9), followUpDate: DateTime(2026, 9, 15, 10)),
      Task(id: 'overdue-open', title: 'کار عقب‌افتاده', dueDate: DateTime(2026, 9, 14, 9)),
      Task(id: 'completed', title: 'کار انجام‌شده', dueDate: DateTime(2026, 9, 15, 8), completed: true),
    ];
    final rawTasks = jsonEncode(tasks.map((task) => task.toJson()).toList());
    SharedPreferences.setMockInitialValues(<String, Object>{TaskStore.key: rawTasks});
    final store = TaskStore();
    final before = await store.load();
    final beforeToday = const HomeTodayProjection().select(before, now: now);
    final beforeDueToday = const TaskDueScopeService().project(before, now: now, scope: TaskDueScope.today);
    final beforeOverdue = const TaskDueScopeService().project(before, now: now, scope: TaskDueScope.overdue);
    final beforeCompleted = before.where((task) => task.completed).length;
    await const PrayerCompletionStore().setStatus(day: now, prayerId: 'prayer-tehran-2026-09-15-fajr', status: PrayerCompletionStatus.completed, updatedAt: DateTime(2026, 9, 15, 12, 1));
    await const PrayerCompletionStore().setStatus(day: now, prayerId: 'prayer-tehran-2026-09-15-dhuhr', status: PrayerCompletionStatus.notCompleted, updatedAt: DateTime(2026, 9, 15, 12, 2));
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(TaskStore.key), rawTasks);
    final after = await store.load();
    expect(after.map((task) => task.toJson()).toList(), before.map((task) => task.toJson()).toList());
    expect(after.length, before.length);
    expect(const HomeTodayProjection().select(after, now: now).map((task) => task.id), beforeToday.map((task) => task.id));
    expect(const TaskDueScopeService().project(after, now: now, scope: TaskDueScope.today).map((task) => task.id), beforeDueToday.map((task) => task.id));
    expect(const TaskDueScopeService().project(after, now: now, scope: TaskDueScope.overdue).map((task) => task.id), beforeOverdue.map((task) => task.id));
    expect(after.where((task) => task.completed).length, beforeCompleted);
    expect(preferences.getString(PrayerCompletionStore.key), isNotNull);
  });
}
