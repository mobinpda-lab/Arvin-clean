import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_taxonomy_lifecycle_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = TaskTaxonomyLifecycleService();

  test('derives categories and tags from canonical Tasks only', () {
    final tasks = [
      Task(id: '1', title: 'الف', category: ' کاری ', tags: ['مهم', 'خانه']),
      Task(id: '2', title: 'ب', category: 'شخصی', tags: ['مهم']),
    ];

    expect(service.categories(tasks), ['شخصی', 'کاری']);
    expect(service.tags(tasks), ['خانه', 'مهم']);
  });

  test('referenced category and tag cannot be destructively deleted', () {
    final tasks = [
      Task(id: '1', title: 'الف', category: 'کاری', tags: ['مهم']),
    ];

    expect(
      () => service.assertCategoryCanDelete(tasks, 'کاری'),
      throwsA(isA<TaxonomyDeleteBlocked>()),
    );
    expect(
      () => service.assertTagCanDelete(tasks, 'مهم'),
      throwsA(isA<TaxonomyDeleteBlocked>()),
    );
  });

  test('unreferenced taxonomy value is safe to delete', () {
    final tasks = [Task(id: '1', title: 'الف', category: 'کاری', tags: ['مهم'])];

    expect(() => service.assertCategoryCanDelete(tasks, 'قدیمی'), returnsNormally);
    expect(() => service.assertTagCanDelete(tasks, 'قدیمی'), returnsNormally);
  });

  test('rename category preserves canonical Task identity and payload', () {
    final task = Task(
      id: 'task-1',
      title: 'عنوان',
      description: 'شرح',
      category: 'قدیمی',
      tags: ['الف'],
    );

    expect(service.renameCategory([task], from: 'قدیمی', to: 'جدید'), 1);
    expect(task.id, 'task-1');
    expect(task.title, 'عنوان');
    expect(task.description, 'شرح');
    expect(task.category, 'جدید');
    expect(task.tags, ['الف']);
  });

  test('rename tag updates references in place and removes duplicates', () {
    final task = Task(
      id: 'task-1',
      title: 'عنوان',
      tags: ['قدیمی', 'جدید', 'دیگر'],
    );

    expect(service.renameTag([task], from: 'قدیمی', to: 'جدید'), 1);
    expect(task.id, 'task-1');
    expect(task.tags, ['جدید', 'دیگر']);
  });
}
