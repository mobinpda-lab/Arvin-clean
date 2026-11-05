import 'package:arvin/models/person_reference.dart';
import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/g1_drift_schema.dart';
import 'package:arvin/services/task_template_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Task Template stores reusable fields but excludes execution dates and history', () async {
    final database = NativeDatabase.memory();
    addTearDown(database.close);
    final store = TaskTemplateStore(executor: database);
    final dueDate = DateTime(2026, 11, 20, 9);
    final reminderDate = DateTime(2026, 11, 18, 8);
    final task = Task(
      id: 'source-task',
      title: 'بازبینی دستگاه',
      description: 'شرح پایدار',
      dueDate: dueDate,
      reminderDate: reminderDate,
      category: 'فنی',
      tags: const ['روزانه', 'ایمنی'],
      checklistEnabled: true,
      checklist: const ['[x] کنترل برق', '[ ] کنترل کابل'],
      priority: TaskPriority.high,
      completed: true,
      completedAt: DateTime(2026, 11, 10),
      people: const [PersonReference(id: 'person-1', displayName: 'همکار')],
      taskReminders: [
        TaskReminder(
          id: 'reminder-1',
          title: 'یادآوری بازبینی',
          date: reminderDate,
          isAllDay: false,
          sequence: 1,
        ),
      ],
      recurrence: RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        interval: 2,
        startDate: DateTime(2026, 11, 1),
        endDate: DateTime(2027, 1, 1),
        count: 8,
      ),
      followUps: [
        FollowUp(
          id: 'follow-up-1',
          dateTime: DateTime(2026, 11, 9),
          note: 'سابقه اجرا',
        ),
      ],
    );

    final template = await store.createFromTask(
      task: task,
      name: 'بازبینی دوره‌ای',
      centerNameSnapshot: 'مرکز نمونه',
      projectNameSnapshot: 'پروژه نمونه',
      now: DateTime(2026, 11, 5),
    );

    final loaded = (await store.load()).single;
    expect(loaded.id, template.id);
    expect(loaded.name, 'بازبینی دوره‌ای');
    expect(loaded.title, task.title);
    expect(loaded.description, task.description);
    expect(loaded.category, task.category);
    expect(loaded.priority, TaskPriority.high);
    expect(loaded.tags, ['روزانه', 'ایمنی']);
    expect(loaded.checklist, ['کنترل برق', 'کنترل کابل']);
    expect(loaded.people.single.id, 'person-1');
    expect(loaded.reminders.single.title, 'یادآوری بازبینی');
    expect(loaded.recurrence?.frequency, RecurrenceFrequency.weekly);
    expect(loaded.recurrence?.interval, 2);
    expect(loaded.recurrence?.startDate, isNull);
    expect(loaded.recurrence?.endDate, isNull);
    expect(loaded.centerNameSnapshot, 'مرکز نمونه');
    expect(loaded.projectNameSnapshot, 'پروژه نمونه');

    final raw = await database.runSelect(
      'SELECT * FROM task_templates WHERE id = ?',
      [template.id],
    );
    expect(raw.single.containsKey('due_date'), isFalse);
    expect(raw.single.containsKey('completed_at'), isFalse);
    expect(raw.single.containsKey('follow_ups'), isFalse);
    expect(raw.single['reminders_json'], isNot(contains(reminderDate.toIso8601String())));

    expect(task.dueDate, dueDate);
    expect(task.reminderDate, reminderDate);
    expect(task.completed, isTrue);
    expect(task.followUps.single.id, 'follow-up-1');
    expect(task.checklist.first, '[x] کنترل برق');
  });

  test('G1 v9 installation adds Task Templates without changing existing Task rows', () async {
    final database = NativeDatabase.memory();
    addTearDown(database.close);
    await database.ensureOpen(G1DriftSchema());
    await database.runCustom(
      "CREATE TABLE tasks (id TEXT NOT NULL PRIMARY KEY, title TEXT NOT NULL, description TEXT NOT NULL, follow_up_enabled INTEGER NOT NULL, priority TEXT NOT NULL, archived INTEGER NOT NULL, trashed INTEGER NOT NULL, completed INTEGER NOT NULL, recurrence_json TEXT NULL)",
    );
    await database.runCustom(
      "INSERT INTO tasks (id, title, description, follow_up_enabled, priority, archived, trashed, completed) VALUES ('legacy-1', 'کار موجود', 'شرح', 0, 'medium', 0, 0, 0)",
    );
    await database.runCustom(
      "CREATE TABLE project_templates (id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, is_archived INTEGER NOT NULL DEFAULT 0, created_at TEXT NOT NULL, updated_at TEXT NOT NULL)",
    );
    await database.runCustom(
      "INSERT INTO project_templates (id, name, created_at, updated_at) VALUES ('project-template-1', 'الگوی موجود', '2026-01-01', '2026-01-01')",
    );

    await G1DriftSchema.install(database);

    final taskRows = await database.runSelect(
      "SELECT id, title FROM tasks WHERE id = 'legacy-1'",
      const [],
    );
    expect(taskRows.single['title'], 'کار موجود');
    final projectRows = await database.runSelect(
      "SELECT name, center_id, color_value FROM project_templates WHERE id = 'project-template-1'",
      const [],
    );
    expect(projectRows.single['name'], 'الگوی موجود');
    expect(projectRows.single['center_id'], isNull);
    expect(projectRows.single['color_value'], 0xFF4A4CAB);
    final taskTemplateTables = await database.runSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'task_templates'",
      const [],
    );
    expect(taskTemplateTables, hasLength(1));
  });
}
