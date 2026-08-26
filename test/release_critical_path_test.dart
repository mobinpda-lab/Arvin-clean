import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/quick_capture_service.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('critical capture to follow-up path survives canonical persistence', () async {
    final createdAt = DateTime.utc(2026, 8, 26, 8, 30);
    final reminderAt = DateTime.utc(2026, 8, 27, 9);
    final nextFollowUp = DateTime.utc(2026, 8, 28, 10);

    final task = const QuickCaptureService().capture(
      'تماس با مشتری #فوری #فروش',
      id: 'release-critical-1',
      createdAt: createdAt,
    )!;
    task.reminderDate = reminderAt;
    task.recurrence = const RecurrenceRule(
      frequency: RecurrenceFrequency.daily,
      interval: 2,
    );

    final store = TaskStore();
    await store.save([task]);
    await store.addFollowUp(
      task.id,
      FollowUp(
        id: 'release-followup-1',
        dateTime: DateTime.utc(2026, 8, 26, 12),
        note: 'پیگیری واقعی مشتری',
        result: 'منتظر پاسخ',
        nextFollowUp: nextFollowUp,
      ),
    );

    final loaded = await store.load();
    expect(loaded, hasLength(1));

    final restored = loaded.single;
    expect(restored.id, 'release-critical-1');
    expect(restored.title, 'تماس با مشتری');
    expect(restored.tags, ['فوری', 'فروش']);
    expect(restored.reminderDate, reminderAt);
    expect(restored.createdAt, createdAt);
    expect(restored.followUpEnabled, isTrue);
    expect(restored.followUps, hasLength(1));
    expect(restored.followUps.single.note, 'پیگیری واقعی مشتری');
    expect(restored.followUps.single.result, 'منتظر پاسخ');
    expect(restored.followUps.single.nextFollowUp, nextFollowUp);
    expect(restored.recurrence?.frequency, RecurrenceFrequency.daily);
    expect(restored.recurrence?.interval, 2);

    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(TaskStore.key);
    expect(raw, isNotNull);
    expect(raw, contains('release-followup-1'));
    expect(raw, contains('"recurrence"'));
    expect(raw, contains('"reminderDate"'));
  });
}
