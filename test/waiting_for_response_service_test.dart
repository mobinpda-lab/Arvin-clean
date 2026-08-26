import 'package:arvin/models/task.dart';
import 'package:arvin/services/waiting_for_response_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = WaitingForResponseService();
  final now = DateTime(2026, 8, 26, 12);

  FollowUp followUp({
    required String id,
    required DateTime date,
    String? result,
    String note = '',
  }) => FollowUp(
        id: id,
        dateTime: date,
        note: note,
        result: result,
      );

  test('uses the latest follow-up result as the waiting state source', () {
    final task = Task(
      id: 't1',
      title: 'پیگیری قرارداد',
      followUps: [
        followUp(
          id: 'old',
          date: now.subtract(const Duration(days: 1)),
          result: WaitingForResponseService.canonicalResult,
        ),
        followUp(
          id: 'new',
          date: now,
          result: 'done',
        ),
      ],
    );

    expect(service.isWaiting(task), isFalse);
  });

  test('recognizes canonical and Persian legacy aliases', () {
    for (final result in [
      'waiting_for_response',
      'waiting',
      'Waiting For Response',
      'منتظر پاسخ',
      'در انتظار پاسخ',
    ]) {
      final task = Task(
        id: result,
        title: 'کار',
        followUps: [followUp(id: 'f', date: now, result: result)],
      );
      expect(service.isWaiting(task), isTrue, reason: result);
    }
  });

  test('completed archived and trashed tasks are never active waiting items', () {
    Task build({bool completed = false, bool archived = false, bool trashed = false}) =>
        Task(
          id: 'state',
          title: 'کار',
          completed: completed,
          archived: archived,
          trashed: trashed,
          followUps: [
            followUp(
              id: 'f',
              date: now,
              result: WaitingForResponseService.canonicalResult,
            ),
          ],
        );

    expect(service.isWaiting(build(completed: true)), isFalse);
    expect(service.isWaiting(build(archived: true)), isFalse);
    expect(service.isWaiting(build(trashed: true)), isFalse);
  });

  test('canonicalizeResult preserves normal results and normalizes waiting', () {
    expect(service.canonicalizeResult('  منتظر   پاسخ  '), 'waiting_for_response');
    expect(service.canonicalizeResult('  موفق  '), 'موفق');
    expect(service.canonicalizeResult('   '), isNull);
    expect(service.canonicalizeResult(null), isNull);
  });

  test('markWaiting preserves follow-up identity and scheduling fields', () {
    final original = FollowUp(
      id: 'f1',
      dateTime: now,
      note: 'تماس با مشتری',
      result: 'بدون پاسخ',
      nextFollowUp: now.add(const Duration(days: 2)),
    );

    final marked = service.markWaiting(original);

    expect(marked.id, original.id);
    expect(marked.dateTime, original.dateTime);
    expect(marked.note, original.note);
    expect(marked.nextFollowUp, original.nextFollowUp);
    expect(marked.result, WaitingForResponseService.canonicalResult);
  });
}
