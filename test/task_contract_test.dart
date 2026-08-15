import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';

void main() {
  test('explicit followUps take precedence over legacy followUpDate', () {
    final task = Task.fromJson({
      'id': 'precedence-1',
      'title': 'اولویت',
      'followUpDate': '2026-08-20T09:30:00.000',
      'followUps': [
        {
          'id': 'explicit-1',
          'dateTime': '2026-08-22T12:00:00.000',
          'note': 'پیگیری صریح',
        },
      ],
    });

    expect(task.followUps, hasLength(1));
    expect(task.followUps.single.id, 'explicit-1');
    expect(task.followUps.single.dateTime,
        DateTime.parse('2026-08-22T12:00:00.000'));
  });

  test('all supported Task fields survive a JSON round trip', () {
    final original = Task(
      id: 'round-trip-1',
      title: 'عنوان',
      description: 'توضیحات',
      createdAt: DateTime.parse('2026-08-01T08:00:00.000'),
      updatedAt: DateTime.parse('2026-08-02T09:00:00.000'),
      followUpEnabled: true,
      followUpDate: DateTime.parse('2026-08-03T10:00:00.000'),
      tags: ['a', 'b'],
      category: 'work',
      checklist: ['one', 'two'],
      reminderDate: DateTime.parse('2026-08-04T11:00:00.000'),
      archived: true,
      completed: true,
      followUps: [
        FollowUp(
          id: 'follow-1',
          dateTime: DateTime.parse('2026-08-05T12:00:00.000'),
          note: 'یادداشت',
          result: 'نتیجه',
          nextFollowUp: DateTime.parse('2026-08-06T13:00:00.000'),
        ),
      ],
      recurrence: const RecurrenceRule(
        frequency: RecurrenceFrequency.monthly,
        interval: 2,
      ),
    );

    final restored = Task.fromJson(original.toJson());

    expect(restored.id, original.id);
    expect(restored.title, original.title);
    expect(restored.description, original.description);
    expect(restored.createdAt, original.createdAt);
    expect(restored.updatedAt, original.updatedAt);
    expect(restored.followUpEnabled, original.followUpEnabled);
    expect(restored.followUpDate, original.followUpDate);
    expect(restored.tags, original.tags);
    expect(restored.category, original.category);
    expect(restored.checklist, original.checklist);
    expect(restored.reminderDate, original.reminderDate);
    expect(restored.archived, original.archived);
    expect(restored.completed, original.completed);
    expect(restored.followUps.single.id, 'follow-1');
    expect(restored.followUps.single.note, 'یادداشت');
    expect(restored.followUps.single.result, 'نتیجه');
    expect(restored.followUps.single.nextFollowUp,
        DateTime.parse('2026-08-06T13:00:00.000'));
    expect(restored.recurrence?.frequency, RecurrenceFrequency.monthly);
    expect(restored.recurrence?.interval, 2);
  });

  test('missing optional legacy fields use current model defaults', () {
    final task = Task.fromJson({
      'id': 'minimal-1',
      'title': 'حداقل',
    });

    expect(task.description, '');
    expect(task.tags, isEmpty);
    expect(task.checklist, isEmpty);
    expect(task.followUps, isEmpty);
    expect(task.followUpEnabled, isFalse);
    expect(task.archived, isFalse);
    expect(task.trashed, isFalse);
    expect(task.completed, isFalse);
    expect(task.recurrence, isNull);
  });

  test('invalid legacy followUpDate does not create a synthetic followUp', () {
    final task = Task.fromJson({
      'id': 'invalid-followup-1',
      'title': 'تاریخ نامعتبر',
      'followUpDate': 'not-a-date',
    });

    expect(task.followUps, isEmpty);
    expect(task.followUpEnabled, isFalse);
  });

  test('multiple explicit followUps preserve identity and order', () {
    final task = Task.fromJson({
      'id': 'multi-followup-1',
      'title': 'چند پیگیری',
      'followUps': [
        {
          'id': 'f1',
          'dateTime': '2026-08-20T09:00:00.000',
          'note': 'اول',
        },
        {
          'id': 'f2',
          'dateTime': '2026-08-21T09:00:00.000',
          'note': 'دوم',
        },
      ],
    });

    expect(task.followUps.map((item) => item.id), ['f1', 'f2']);
    expect(task.followUps.map((item) => item.note), ['اول', 'دوم']);
  });
}
