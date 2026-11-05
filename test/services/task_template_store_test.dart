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
      people: [PersonReference(id: 'person-1', displayName: 'همکار')],
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
      centerIdSnapshot: 'center-1',
      projectIdSnapshot: 'project-1',
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
    expect(loaded.checklistEnabled, isTrue);
    expect(loaded.people.single.id, 'person-1');
    expect(loaded.reminders.single.title, 'یادآوری بازبینی');
    expect(loaded.reminders.single.hour, 8);
    expect(loaded.reminders.single.minute, 0);
    expect(loaded.reminders.single.isEnabled, isTrue);
    expect(loaded.recurrence?.frequency, RecurrenceFrequency.weekly);
    expect(loaded.recurrence?.interval, 2);
    expect(loaded.recurrence?.startDate, DateTime(2026, 11, 1));
    expect(loaded.recurrence?.endDate, DateTime(2027, 1, 1));
    expect(loaded.centerNameSnapshot, 'مرکز نمونه');
    expect(loaded.projectNameSnapshot, 'پروژه نمونه');
    expect(loaded.centerIdSnapshot, 'center-1');
    expect(loaded.projectIdSnapshot, 'project-1');

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

  test('G1 v11 migration adds checklist configuration without changing existing Task or Task Template rows', () async {
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
      "CREATE TABLE task_templates (id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, title TEXT NOT NULL, description TEXT NOT NULL DEFAULT '', category TEXT NULL, priority TEXT NOT NULL DEFAULT 'medium', tags_json TEXT NOT NULL DEFAULT '[]', checklist_json TEXT NOT NULL DEFAULT '[]', people_json TEXT NOT NULL DEFAULT '[]', reminders_json TEXT NOT NULL DEFAULT '[]', recurrence_json TEXT NULL, center_name_snapshot TEXT NULL, project_name_snapshot TEXT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, is_archived INTEGER NOT NULL DEFAULT 0)",
    );
    await database.runCustom(
      "INSERT INTO task_templates (id, name, title, created_at, updated_at) VALUES ('task-template-v9', 'الگوی قدیمی', 'کار قدیمی', '2026-01-01', '2026-01-01')",
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
    final templateColumns = await database.runSelect(
      "PRAGMA table_info('task_templates')",
      const [],
    );
    expect(templateColumns.map((row) => row['name']), containsAll([
      'center_id_snapshot',
      'project_id_snapshot',
      'checklist_enabled',
    ]));
    final oldTemplate = await database.runSelect(
      "SELECT name, title FROM task_templates WHERE id = 'task-template-v9'",
      const [],
    );
    expect(oldTemplate.single['name'], 'الگوی قدیمی');
    expect(oldTemplate.single['title'], 'کار قدیمی');
    final legacyChecklistConfig = await database.runSelect(
      "SELECT checklist_enabled FROM task_templates WHERE id = 'task-template-v9'",
      const [],
    );
    expect(legacyChecklistConfig.single['checklist_enabled'], 0);
  });

  test('Task Template retains legacy reminder time without copying its calendar date', () async {
    final database = NativeDatabase.memory();
    addTearDown(database.close);
    final store = TaskTemplateStore(executor: database);
    final executionDate = DateTime(2026, 11, 18, 8, 45);
    final task = Task(
      id: 'legacy-reminder-source',
      title: 'کار دارای یادآور قدیمی',
      reminderDate: executionDate,
    );

    final saved = await store.createFromTask(
      task: task,
      name: 'الگوی یادآور صبحگاهی',
      now: DateTime(2026, 11, 5),
    );
    final reminder = saved.reminders.single;
    expect(reminder.title, 'یادآور اصلی');
    expect(reminder.hour, 8);
    expect(reminder.minute, 45);
    expect(saved.toColumns()['reminders_json'], isNot(contains('2026-11-18')));
    expect(task.reminderDate, executionDate);
  });


  test('Task Template preserves an enabled but empty reusable checklist', () async {
    final database = NativeDatabase.memory();
    addTearDown(database.close);
    final store = TaskTemplateStore(executor: database);
    final template = await store.createFromTask(
      task: Task(
        id: 'empty-checklist-source',
        title: 'کار با چک‌لیست خالی',
        checklistEnabled: true,
        checklist: const [],
      ),
      name: 'الگوی چک‌لیست خالی',
      now: DateTime(2026, 11, 5),
    );
    expect(template.checklist, isEmpty);
    expect(template.checklistEnabled, isTrue);
    expect((await store.load()).single.checklistEnabled, isTrue);
  });

}
