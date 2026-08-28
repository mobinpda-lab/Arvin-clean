import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_bulk_mutation_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final changedAt = DateTime(2026, 8, 28, 15);
  late TaskBulkMutationService service;

  setUp(() {
    service = TaskBulkMutationService(now: () => changedAt);
  });

  Task task(
    String id, {
    String? category,
    List<String> tags = const [],
    bool trashed = false,
  }) {
    return Task(
      id: id,
      title: 'Task $id',
      category: category,
      tags: List<String>.of(tags),
      trashed: trashed,
      dueDate: DateTime(2026, 9, 1, 9),
      reminderDate: DateTime(2026, 9, 1, 8),
      followUpEnabled: true,
      followUpDate: DateTime(2026, 9, 2, 10),
      followUps: [
        FollowUp(
          id: 'f-$id',
          dateTime: DateTime(2026, 8, 27, 11),
          note: 'history $id',
        ),
      ],
    );
  }

  test('moveToTrash changes only selected canonical task instances', () {
    final first = task('1');
    final second = task('2');
    final tasks = [first, second];
    final originalFollowUp = first.followUps.single;

    final changed = service.moveToTrash(tasks, {'1', 'missing'});

    expect(changed, 1);
    expect(identical(tasks.first, first), isTrue);
    expect(tasks, hasLength(2));
    expect(first.trashed, isTrue);
    expect(first.updatedAt, changedAt);
    expect(first.followUps.single, same(originalFollowUp));
    expect(first.dueDate, DateTime(2026, 9, 1, 9));
    expect(first.reminderDate, DateTime(2026, 9, 1, 8));
    expect(second.trashed, isFalse);
    expect(second.updatedAt, isNull);
  });

  test('moveToCategory reassigns selected tasks without copies', () {
    final first = task('1', category: 'قدیم');
    final second = task('2', category: 'ثابت');
    final tasks = [first, second];

    final changed = service.moveToCategory(tasks, {'1'}, '  مشتریان  ');

    expect(changed, 1);
    expect(tasks, [same(first), same(second)]);
    expect(first.category, 'مشتریان');
    expect(first.updatedAt, changedAt);
    expect(second.category, 'ثابت');
    expect(second.updatedAt, isNull);
  });

  test('blank bulk category clears only selected assignment', () {
    final first = task('1', category: 'مشتریان');
    final second = task('2', category: 'مهم');

    final changed = service.moveToCategory([first, second], {'1'}, '   ');

    expect(changed, 1);
    expect(first.category, isNull);
    expect(second.category, 'مهم');
  });

  test('addTags preserves existing tags and deterministically de-duplicates', () {
    final first = task('1', tags: ['مهم', 'قدیمی']);
    final second = task('2', tags: ['دست‌نخورده']);

    final changed = service.addTags(
      [first, second],
      {'1'},
      [' جدید ', 'مهم', '', 'جدید'],
    );

    expect(changed, 1);
    expect(first.tags, ['مهم', 'قدیمی', 'جدید']);
    expect(first.updatedAt, changedAt);
    expect(second.tags, ['دست‌نخورده']);
    expect(second.updatedAt, isNull);
  });

  test('no-op selections do not rewrite updatedAt', () {
    final first = task('1', category: 'مشتریان', tags: ['مهم'], trashed: true);

    expect(service.moveToTrash([first], {'1'}), 0);
    expect(service.moveToCategory([first], {'1'}, 'مشتریان'), 0);
    expect(service.addTags([first], {'1'}, ['مهم']), 0);
    expect(first.updatedAt, isNull);
  });
}
