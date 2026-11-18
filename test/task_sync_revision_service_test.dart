import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_sync_revision_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = TaskSyncRevisionService();

  test('same canonical Task produces the same stable fingerprint', () async {
    final task = Task(
      id: 'task-1',
      title: 'پیگیری قرارداد',
      description: 'نسخه اصلی',
      createdAt: DateTime.utc(2026, 8, 27, 8),
      updatedAt: DateTime.utc(2026, 8, 27, 9),
      tags: const ['حقوقی', 'فوری'],
    );

    final first = await service.fromTask(task);
    final second = await service.fromTask(task);

    expect(first.id, 'task-1');
    expect(first.fingerprint, second.fingerprint);
    expect(first.fingerprint, hasLength(64));
    expect(first.fingerprint, matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(first.modifiedAt, DateTime.utc(2026, 8, 27, 9));
  });

  test('canonical content changes produce a different revision', () async {
    final task = Task(id: 'task-1', title: 'نسخه اول');

    final before = await service.fromTask(task);
    task.title = 'نسخه دوم';
    final after = await service.fromTask(task);

    expect(after.id, before.id);
    expect(after.fingerprint, isNot(before.fingerprint));
  });

  test('createdAt is used when updatedAt is unavailable', () async {
    final createdAt = DateTime.utc(2026, 8, 27, 10);
    final revision = await service.fromTask(
      Task(id: 'task-2', title: 'کار', createdAt: createdAt),
    );

    expect(revision.modifiedAt, createdAt);
  });

  test('empty canonical Task id is rejected', () async {
    expect(
      () => service.fromTask(Task(id: '', title: 'بدون شناسه')),
      throwsArgumentError,
    );
  });
}
