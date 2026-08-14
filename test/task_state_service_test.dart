import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_state_service.dart';

void main() {
  test('archive moves a task out of active and trash states', () {
    final task = ArvinTask(id: '1', title: 'کار');
    const service = TaskStateService();

    service.archive(task);

    expect(task.archived, isTrue);
    expect(task.trashed, isFalse);
  });

  test('archive can be restored to active', () {
    final task = ArvinTask(id: '1', title: 'کار', archived: true);
    const service = TaskStateService();

    service.restoreFromArchive(task);

    expect(task.archived, isFalse);
    expect(task.trashed, isFalse);
  });

  test('trash and restore preserve an explicit active destination', () {
    final task = ArvinTask(id: '1', title: 'کار', archived: true);
    const service = TaskStateService();

    service.moveToTrash(task);
    expect(task.trashed, isTrue);
    expect(task.archived, isFalse);

    service.restoreFromTrash(task);
    expect(task.trashed, isFalse);
    expect(task.archived, isFalse);
  });
}
