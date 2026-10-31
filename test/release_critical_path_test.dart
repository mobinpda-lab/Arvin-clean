import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/quick_capture_service.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    await TaskStore.resetTestDatabase();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });
  test('critical capture to independent reminder path survives canonical persistence', () async {
    final createdAt = DateTime.utc(2026, 8, 26, 8, 30);
    final reminderAt = DateTime.utc(2026, 8, 27, 9);

    final task = const QuickCaptureService().capture(
      'تماس با مشتری #فوری #فروش',
      id: 'release-critical-1',
      createdAt: createdAt,
    )!;
    task.taskReminders = [
      TaskReminder(
        id: 'release-reminder-1',
        title: 'یادآور مستقل مشتری',
        date: reminderAt,
        sequence: 1,
      ),
    ];
    task.nextReminderSequence = 2;
    task.recurrence = const RecurrenceRule(
      frequency: RecurrenceFrequency.daily,
      interval: 2,
    );

    final store = TaskStore();
    await store.save([task]);
    final loaded = await store.load();
    expect(loaded, hasLength(1));

    final restored = loaded.single;
    expect(restored.id, 'release-critical-1');
    expect(restored.title, 'تماس با مشتری');
    expect(restored.tags, ['فوری', 'فروش']);
    expect(restored.reminderDate, isNull);
    expect(restored.createdAt, createdAt);
    expect(restored.followUpEnabled, isFalse);
    expect(restored.followUps, isEmpty);
    expect(restored.taskReminders, hasLength(1));
    expect(restored.taskReminders.single.id, 'release-reminder-1');
    expect(restored.taskReminders.single.date, reminderAt);
    expect(restored.taskReminders.single.sequence, 1);
    expect(restored.recurrence?.frequency, RecurrenceFrequency.daily);
    expect(restored.recurrence?.interval, 2);

    final persisted = (await TaskStore().load()).single;
    expect(persisted.followUps, isEmpty);
    expect(persisted.taskReminders.single.id, 'release-reminder-1');
    expect(persisted.recurrence, isNotNull);
    expect(persisted.reminderDate, isNull);
  });
}
