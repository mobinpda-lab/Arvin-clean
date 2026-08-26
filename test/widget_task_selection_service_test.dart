import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/services/widget_task_selection_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('reloads Widget Task id from canonical arvin.tasks storage', () async {
    final store = TaskStore();
    await store.save([
      Task(id: 'task-42', title: 'کار انتخاب‌شده'),
      Task(id: 'other', title: 'کار دیگر'),
    ]);

    final task = await WidgetTaskSelectionService().loadTask(' task-42 ');

    expect(task?.id, 'task-42');
    expect(task?.title, 'کار انتخاب‌شده');
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getKeys(), contains(TaskStore.key));
    expect(preferences.getKeys(), hasLength(1));
  });

  test('ignores missing, empty and trashed Widget Task ids', () async {
    final store = TaskStore();
    await store.save([
      Task(id: 'trashed', title: 'حذف‌شده', trashed: true),
    ]);
    final service = WidgetTaskSelectionService();

    expect(await service.loadTask(''), isNull);
    expect(await service.loadTask('missing'), isNull);
    expect(await service.loadTask('trashed'), isNull);
  });
}
