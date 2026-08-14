import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';

void main() {
  test('a task without follow-ups behaves as a simple note', () {
    final task = Task(id: '1', title: 'یادداشت');

    expect(task.isSimpleNote, isTrue);
    expect(task.followUpEnabled, isFalse);
  });

  test('enabling follow-up keeps the same item and exposes follow-up state', () {
    final task = Task(
      id: '1',
      title: 'کار',
      followUpEnabled: true,
    );

    expect(task.isSimpleNote, isFalse);
    expect(task.id, '1');
  });

  test('new unified fields survive serialization without breaking legacy fields', () {
    final created = DateTime(2026, 8, 14, 10, 30);
    final reminder = DateTime(2026, 8, 15, 9);
    final task = Task(
      id: '1',
      title: 'کار',
      description: 'توضیح',
      createdAt: created,
      category: 'پیگیری مشتری',
      followUpEnabled: true,
      checklist: const ['تماس', 'ثبت نتیجه'],
      reminderDate: reminder,
      followUps: [
        FollowUp(id: 'f1', dateTime: created, note: 'تماس انجام شد'),
      ],
    );

    final restored = Task.fromJson(task.toJson());

    expect(restored.id, '1');
    expect(restored.createdAt, created);
    expect(restored.category, 'پیگیری مشتری');
    expect(restored.followUpEnabled, isTrue);
    expect(restored.checklist, ['تماس', 'ثبت نتیجه']);
    expect(restored.reminderDate, reminder);
    expect(restored.followUps.single.note, 'تماس انجام شد');
  });

  test('legacy followUpDate data still migrates into follow-up history', () {
    final legacyDate = DateTime(2026, 8, 13, 12);
    final task = Task.fromJson({
      'id': 'legacy',
      'title': 'قدیمی',
      'followUpDate': legacyDate.toIso8601String(),
    });

    expect(task.followUpEnabled, isTrue);
    expect(task.followUps, hasLength(1));
    expect(task.followUps.single.dateTime, legacyDate);
  });

  test('missing category remains backward-compatible with legacy data', () {
    final task = Task.fromJson({
      'id': 'legacy',
      'title': 'قدیمی',
    });

    expect(task.category, isNull);
    expect(task.toJson()['category'], isNull);
  });
}
