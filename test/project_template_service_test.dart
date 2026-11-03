import 'package:arvin/models/project_template.dart';
import 'package:arvin/services/center_store.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/project_template_service.dart';
import 'package:arvin/services/project_template_store.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });
  test('template creates independent projects and propagation is append-only and idempotent', () async {
    final db = NativeDatabase.memory(); addTearDown(db.close);
    final centers = CenterStore(executor: db);
    final templates = ProjectTemplateStore(executor: db);
    final projects = ProjectStore(executor: db);
    final tasks = TaskStore(executor: db);
    await centers.create(id: '511', name: '511');
    await centers.create(id: '512', name: '512');
    await centers.create(id: '513', name: '513');
    final now = DateTime(2026, 11, 3);
    final base = ProjectTemplateTask(id: 'tt-base', title: 'بررسی فن', category: 'سرویس');
    final second = ProjectTemplateTask(id: 'tt-second', title: 'بررسی واشر');
    final template = ProjectTemplate(id: 'tpl', name: 'کالیبراسیون یخچال', tasks: [base, second], createdAt: now, updatedAt: now);
    await templates.save(template);
    var generatedId = 0;
    final service = ProjectTemplateService(templateStore: templates, centerStore: centers, projectStore: projects, taskStore: tasks, idFactory: (prefix) => '$prefix-${generatedId++}');
    final generated = await service.generateProjects(templateId: 'tpl', centerIds: {'511', '512', '513'});
    expect(generated.created.length, 3);
    final retryGeneration = await service.generateProjects(templateId: 'tpl', centerIds: {'511', '512', '513'});
    expect(retryGeneration.duplicates.length, 3);
    final createdProjects = await projects.load();
    expect(createdProjects.map((p) => p.centerId).toSet(), {'511', '512', '513'});
    expect(createdProjects.expand((p) => p.itemIds).toSet().length, 6);
    final project511 = createdProjects.firstWhere((p) => p.centerId == '511');
    final task511 = (await tasks.load()).firstWhere((task) => project511.itemIds.contains(task.id) && task.templateTaskId == 'tt-base');
    task511.setCompleted(true, at: now);
    task511.archived = true;
    task511.checklistEnabled = true;
    task511.checklist = ['[x] سابقه چک‌لیست'];
    task511.taskReminders = [
      TaskReminder(
        id: 'preserved-reminder',
        title: 'یادآور مستقل موجود',
        date: now.add(const Duration(days: 2)),
        sequence: 1,
      ),
    ];
    task511.followUps = [
      FollowUp(
        id: 'preserved-follow-up',
        dateTime: now.subtract(const Duration(days: 1)),
        note: 'سابقه واقعی باید حفظ شود',
      ),
    ];
    await tasks.save(await tasks.load().then((all) => all.map((t) => t.id == task511.id ? task511 : t).toList()));
    final appended = ProjectTemplateTask(id: 'tt-new', title: 'تمیزکاری فیلتر پشت کندانسور');
    final updated = template.copyWith(tasks: [...template.tasks, appended], updatedAt: now);
    await templates.save(updated);
    final archivedProject = createdProjects.firstWhere((p) => p.centerId == '513');
    await projects.save(createdProjects.map((p) => p.id == archivedProject.id ? p.copyWith(isArchived: true) : p).toList());
    final eligible = await service.propagationCandidates('tpl');
    expect(eligible.eligible.length, 2);
    expect(eligible.ineligible.map((p) => p.id), [archivedProject.id]);
    final result = await service.propagateTask(templateId: 'tpl', templateTask: appended, selectedProjectIds: eligible.eligible.map((p) => p.id).toSet());
    expect(result.applied.length, 2);
    expect(result.ineligible, isEmpty);
    final after = await projects.load();
    final afterTasks = await tasks.load();
    final preserved = afterTasks.firstWhere((t) => t.id == task511.id);
    expect(preserved.completed, isTrue);
    expect(preserved.archived, isTrue);
    expect(preserved.completedAt, now);
    expect(preserved.checklistEnabled, isTrue);
    expect(preserved.checklist, ['[x] سابقه چک‌لیست']);
    expect(preserved.taskReminders, hasLength(1));
    expect(preserved.taskReminders.single.id, 'preserved-reminder');
    expect(preserved.taskReminders.single.date, now.add(const Duration(days: 2)));
    expect(preserved.followUps, hasLength(1));
    expect(preserved.followUps.single.id, 'preserved-follow-up');
    expect(preserved.followUps.single.dateTime, now.subtract(const Duration(days: 1)));
    expect(preserved.followUps.single.note, 'سابقه واقعی باید حفظ شود');
    expect(after.where((p) => p.itemIds.map((id) => afterTasks.firstWhere((t) => t.id == id)).any((t) => t.templateTaskId == 'tt-new')).length, 2);
    expect(after.firstWhere((p) => p.centerId == '511').itemIds, contains(task511.id));
    expect(after.firstWhere((p) => p.centerId == '513').itemIds.length, 2);
    final retry = await service.propagateTask(templateId: 'tpl', templateTask: appended, selectedProjectIds: eligible.eligible.map((p) => p.id).toSet());
    expect(retry.alreadyPresent.length, 2);
    expect((await tasks.load()).length, afterTasks.length);
  });
}
