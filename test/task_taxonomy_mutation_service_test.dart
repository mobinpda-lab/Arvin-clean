import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_taxonomy_mutation_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final changedAt = DateTime(2026, 8, 28, 16, 30);
  final service = TaskTaxonomyMutationService(now: () => changedAt);

  Task task({
    required String id,
    String? category,
    List<String> tags = const [],
  }) =>
      Task(
        id: id,
        title: 'Task $id',
        category: category,
        tags: List<String>.of(tags),
        dueDate: DateTime(2026, 8, 30, 9),
        reminderDate: DateTime(2026, 8, 29, 9),
        followUps: [
          FollowUp(id: 'fu-$id', dateTime: DateTime(2026, 8, 28, 12)),
        ],
      );

  test('renames category in place without replacing canonical item state', () {
    final original = task(id: '1', category: 'فروش', tags: ['مهم']);
    final tasks = [original, task(id: '2', category: 'شخصی')];

    final changed = service.renameCategory(
      tasks,
      from: 'فروش',
      to: 'مشتریان',
    );

    expect(changed, 1);
    expect(identical(tasks.first, original), isTrue);
    expect(original.id, '1');
    expect(original.category, 'مشتریان');
    expect(original.tags, ['مهم']);
    expect(original.followUps.single.id, 'fu-1');
    expect(original.dueDate, DateTime(2026, 8, 30, 9));
    expect(original.reminderDate, DateTime(2026, 8, 29, 9));
    expect(original.updatedAt, changedAt);
  });

  test('deleting category only clears assignment and never deletes item', () {
    final tasks = [
      task(id: '1', category: 'فروش'),
      task(id: '2', category: 'فروش'),
      task(id: '3', category: 'شخصی'),
    ];

    final changed = service.deleteCategory(tasks, 'فروش');

    expect(changed, 2);
    expect(tasks, hasLength(3));
    expect(tasks[0].category, isNull);
    expect(tasks[1].category, isNull);
    expect(tasks[2].category, 'شخصی');
  });

  test('renaming tag de-duplicates target and preserves unrelated tags', () {
    final tasks = [
      task(id: '1', tags: ['قدیمی', 'مهم', 'جدید']),
      task(id: '2', tags: ['قدیمی']),
      task(id: '3', tags: ['دیگر']),
    ];

    final changed = service.renameTag(tasks, from: 'قدیمی', to: 'جدید');

    expect(changed, 2);
    expect(tasks[0].tags, ['جدید', 'مهم']);
    expect(tasks[1].tags, ['جدید']);
    expect(tasks[2].tags, ['دیگر']);
  });

  test('deleting tag removes association only from matching items', () {
    final tasks = [
      task(id: '1', tags: ['مهم', 'فروش']),
      task(id: '2', tags: ['فروش']),
      task(id: '3', tags: ['شخصی']),
    ];

    final changed = service.deleteTag(tasks, 'فروش');

    expect(changed, 2);
    expect(tasks[0].tags, ['مهم']);
    expect(tasks[1].tags, isEmpty);
    expect(tasks[2].tags, ['شخصی']);
  });

  test('blank or no-op taxonomy changes do nothing', () {
    final tasks = [task(id: '1', category: 'فروش', tags: ['مهم'])];

    expect(service.renameCategory(tasks, from: 'فروش', to: 'فروش'), 0);
    expect(service.renameCategory(tasks, from: ' ', to: 'جدید'), 0);
    expect(service.deleteCategory(tasks, ' '), 0);
    expect(service.renameTag(tasks, from: 'مهم', to: 'مهم'), 0);
    expect(service.deleteTag(tasks, ' '), 0);
    expect(tasks.single.category, 'فروش');
    expect(tasks.single.tags, ['مهم']);
  });
}
