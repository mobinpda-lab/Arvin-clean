import 'package:arvin/models/task.dart';
import 'package:arvin/services/home_list_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const projection = HomeListProjection();
  final now = DateTime(2026, 8, 28, 16);

  test('completed Tasks stay out of Today Future and Overdue active scopes', () {
    final tasks = [
      Task(
        id: 'today',
        title: 'today',
        completed: true,
        dueDate: DateTime(2026, 8, 28, 9),
      ),
      Task(
        id: 'future',
        title: 'future',
        completed: true,
        dueDate: DateTime(2026, 8, 29, 9),
      ),
      Task(
        id: 'overdue',
        title: 'overdue',
        completed: true,
        dueDate: DateTime(2026, 8, 27, 9),
      ),
    ];

    for (final scope in [
      HomeListScope.today,
      HomeListScope.future,
      HomeListScope.overdue,
    ]) {
      expect(
        projection.project(
          tasks,
          scope: scope,
          sort: HomeListSort.date,
          now: now,
        ),
        isEmpty,
      );
    }
  });
}
