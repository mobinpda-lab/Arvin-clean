import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_bulk_selection_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = TaskBulkSelectionService();

  Task task(String id) => Task(id: id, title: 'Task $id');

  test('toggle adds and removes exactly one task id', () {
    expect(service.toggle({'1'}, '2'), {'1', '2'});
    expect(service.toggle({'1', '2'}, '2'), {'1'});
  });

  test('selectAll selects only visible ids while preserving hidden selection', () {
    final result = service.selectAll(
      {'hidden'},
      [task('1'), task('2')],
    );

    expect(result, {'hidden', '1', '2'});
  });

  test('selectAll toggles visible selection off when all visible are selected', () {
    final result = service.selectAll(
      {'hidden', '1', '2'},
      [task('1'), task('2')],
    );

    expect(result, {'hidden'});
  });

  test('empty visible list never destroys existing selection', () {
    expect(service.selectAll({'1'}, const <Task>[]), {'1'});
    expect(service.allVisibleSelected({'1'}, const <Task>[]), isFalse);
  });

  test('reconcile removes stale ids after canonical collection changes', () {
    final result = service.reconcile(
      {'1', 'missing', '3'},
      [task('1'), task('2'), task('3')],
    );

    expect(result, {'1', '3'});
  });

  test('allVisibleSelected ignores selected tasks outside current view', () {
    expect(
      service.allVisibleSelected({'1', '2', 'hidden'}, [task('1'), task('2')]),
      isTrue,
    );
    expect(
      service.allVisibleSelected({'1', 'hidden'}, [task('1'), task('2')]),
      isFalse,
    );
  });

  test('selectedTasks returns canonical instances in canonical order', () {
    final first = task('1');
    final second = task('2');
    final third = task('3');

    final result = service.selectedTasks(
      [first, second, third],
      {'3', '1'},
    );

    expect(result, [same(first), same(third)]);
  });
}
