import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_edit_apply_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final appliedAt = DateTime(2026, 8, 28, 17);
  final service = TaskEditApplyService(now: () => appliedAt);

  test('applies due date and other editable fields to canonical Task', () {
    final originalFollowUps = [
      FollowUp(
        id: 'fu-1',
        dateTime: DateTime(2026, 8, 27, 10),
        note: 'سابقه',
      ),
    ];
    final target = Task(
      id: 'task-1',
      title: 'قدیمی',
      description: 'قبل',
      dueDate: DateTime(2026, 8, 29, 9),
      followUpEnabled: true,
      followUpDate: DateTime(2026, 8, 29, 10),
      tags: ['قدیمی'],
      category: 'فروش',
      checklist: ['یک'],
      reminderDate: DateTime(2026, 8, 29, 8),
      archived: true,
      completed: true,
      followUps: originalFollowUps,
      createdAt: DateTime(2026, 8, 20),
    );
    final edited = Task(
      id: 'task-1',
      title: 'جدید',
      description: 'بعد',
      dueDate: DateTime(2026, 8, 30, 14),
      followUpEnabled: false,
      tags: ['مهم', 'مشتری'],
      category: 'مشتریان',
      checklist: ['یک', 'دو'],
      reminderDate: DateTime(2026, 8, 30, 12),
      archived: false,
      completed: false,
      followUps: const [],
      createdAt: DateTime(2026, 8, 28),
    );

    service.apply(target, edited);

    expect(target.title, 'جدید');
    expect(target.description, 'بعد');
    expect(target.dueDate, DateTime(2026, 8, 30, 14));
    expect(target.followUpEnabled, isFalse);
    expect(target.followUpDate, isNull);
    expect(target.tags, ['مهم', 'مشتری']);
    expect(target.category, 'مشتریان');
    expect(target.checklist, ['یک', 'دو']);
    expect(target.reminderDate, DateTime(2026, 8, 30, 12));
    expect(target.updatedAt, appliedAt);
  });

  test('preserves identity history and non-editor lifecycle flags', () {
    final history = FollowUp(
      id: 'fu-history',
      dateTime: DateTime(2026, 8, 27, 10),
    );
    final createdAt = DateTime(2026, 8, 20);
    final target = Task(
      id: 'canonical-id',
      title: 'قبل',
      archived: true,
      trashed: true,
      completed: true,
      followUps: [history],
      createdAt: createdAt,
    );
    final edited = Task(
      id: 'different-editor-copy-id',
      title: 'بعد',
      archived: false,
      trashed: false,
      completed: false,
      followUps: const [],
      createdAt: DateTime(2026, 8, 28),
    );

    service.apply(target, edited);

    expect(target.id, 'canonical-id');
    expect(target.followUps, hasLength(1));
    expect(identical(target.followUps.single, history), isTrue);
    expect(target.createdAt, createdAt);
    expect(target.archived, isTrue);
    expect(target.trashed, isTrue);
    expect(target.completed, isTrue);
  });

  test('copies mutable collections instead of aliasing editor lists', () {
    final edited = Task(
      id: 'task-1',
      title: 'عنوان',
      tags: ['الف'],
      checklist: ['یک'],
    );
    final target = Task(id: 'task-1', title: 'قبل');

    service.apply(target, edited);
    edited.tags.add('ب');
    edited.checklist.add('دو');

    expect(target.tags, ['الف']);
    expect(target.checklist, ['یک']);
  });
}
