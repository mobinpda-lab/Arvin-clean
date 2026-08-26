import 'package:arvin/models/task.dart';
import 'package:arvin/services/widget_follow_up_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const projection = WidgetFollowUpProjection();

  test('uses latest FollowUp and orders newest active tasks first', () {
    final tasks = [
      Task(
        id: 'a',
        title: 'مشتری الف',
        followUps: [
          FollowUp(id: 'a1', dateTime: DateTime(2026, 8, 20), note: 'قدیمی'),
          FollowUp(
            id: 'a2',
            dateTime: DateTime(2026, 8, 26, 10),
            note: 'آخرین پیگیری',
            result: 'منتظر پاسخ',
          ),
        ],
      ),
      Task(
        id: 'b',
        title: 'مشتری ب',
        followUps: [
          FollowUp(id: 'b1', dateTime: DateTime(2026, 8, 26, 12), note: 'جدیدتر'),
        ],
      ),
    ];

    final result = projection.project(tasks);

    expect(result.map((item) => item.taskId), ['b', 'a']);
    expect(result.last.note, 'آخرین پیگیری');
    expect(result.last.result, 'منتظر پاسخ');
  });

  test('excludes inactive items and limits output', () {
    Task item(String id, {bool archived = false, bool trashed = false, bool completed = false}) =>
        Task(
          id: id,
          title: id,
          archived: archived,
          trashed: trashed,
          completed: completed,
          followUps: [
            FollowUp(id: '$id-f', dateTime: DateTime(2026, 8, 26), note: id),
          ],
        );

    final result = projection.project(
      [
        item('active-1'),
        item('active-2'),
        item('active-3'),
        item('active-4'),
        item('archived', archived: true),
        item('trashed', trashed: true),
        item('done', completed: true),
      ],
      limit: 3,
    );

    expect(result, hasLength(3));
    expect(result.map((item) => item.taskId), everyElement(startsWith('active-')));
  });

  test('empty title uses canonical fallback', () {
    final result = projection.project([
      Task(
        id: 'empty',
        title: '   ',
        followUps: [
          FollowUp(id: 'f', dateTime: DateTime(2026, 8, 26), note: 'پیگیری'),
        ],
      ),
    ]);

    expect(result.single.title, 'بدون عنوان');
  });
}
