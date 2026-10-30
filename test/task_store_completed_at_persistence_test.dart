import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  test('SQL persistence round-trips completedAt and preserves follow-up history', () async {
    final database = NativeDatabase.memory();
    try {
      final store = TaskStore(executor: database);
      final completedAt = DateTime.parse('2026-10-30T10:15:00.000Z');
      final task = Task(
        id: 'completed-sql-1', title: 'کار تکمیل‌شده', completed: true,
        completedAt: completedAt,
        followUps: [FollowUp(id: 'history-1', dateTime: DateTime.parse('2026-10-29T09:00:00.000Z'), note: 'تاریخچه قبلی')],
      );
      await store.save([task]);
      final restored = (await store.load()).single;
      expect(restored.completed, isTrue);
      expect(restored.completedAt, completedAt);
      expect(restored.followUps, hasLength(1));
      expect(restored.followUps.single.id, 'history-1');
      expect(restored.followUps.single.note, 'تاریخچه قبلی');
    } finally { await database.close(); }
  });
}
