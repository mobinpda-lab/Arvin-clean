import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_bulk_report_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = TaskBulkReportService();
  final generatedAt = DateTime(2026, 8, 28, 16, 45);

  Task task(String id, {bool trashed = false}) => Task(
        id: id,
        title: 'Task $id',
        trashed: trashed,
        followUps: [
          FollowUp(
            id: 'fu-$id-1',
            dateTime: DateTime(2026, 8, 27, 10),
            note: 'اول',
          ),
          FollowUp(
            id: 'fu-$id-2',
            dateTime: DateTime(2026, 8, 28, 11),
            note: 'دوم',
          ),
        ],
      );

  test('selected scope reuses canonical projection and preserves follow-ups', () {
    final report = service.selected(
      [task('1'), task('2'), task('3')],
      {'3', '1'},
      generatedAt: generatedAt,
    );

    expect(report.generatedAt, generatedAt);
    expect(report.entries.map((entry) => entry.id), ['1', '3']);
    expect(report.entries.first.followUps.map((item) => item.id), [
      'fu-1-1',
      'fu-1-2',
    ]);
    expect(report.entries.last.followUps.map((item) => item.id), [
      'fu-3-1',
      'fu-3-2',
    ]);
  });

  test('visible scope reports exactly supplied visible canonical items', () {
    final report = service.visible(
      [task('2'), task('4')],
      generatedAt: generatedAt,
    );

    expect(report.entries.map((entry) => entry.id), ['2', '4']);
  });

  test('trashed items remain excluded by the canonical report contract', () {
    final report = service.selected(
      [task('1'), task('2', trashed: true)],
      {'1', '2'},
      generatedAt: generatedAt,
    );

    expect(report.entries.map((entry) => entry.id), ['1']);
  });

  test('empty selected scope produces an empty report without mutation', () {
    final original = task('1');
    final report = service.selected(
      [original],
      const <String>{},
      generatedAt: generatedAt,
    );

    expect(report.entries, isEmpty);
    expect(original.followUps, hasLength(2));
    expect(original.trashed, isFalse);
  });
}
