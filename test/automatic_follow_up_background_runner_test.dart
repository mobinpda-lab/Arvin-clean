import 'package:arvin/automatic_follow_up_background_runner.dart';
import 'package:arvin/automatic_follow_up_notification_service.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/automatic_follow_up_service.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final now = DateTime(2026, 8, 26, 12);

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('delivers each due latest follow-up only once', () async {
    final store = _FakeTaskStore([
      Task(
        id: 't1',
        title: 'تماس مشتری',
        followUps: [
          FollowUp(
            id: 'f1',
            dateTime: DateTime(2026, 8, 25, 10),
            nextFollowUp: DateTime(2026, 8, 26, 11),
          ),
        ],
      ),
    ]);
    final sink = _FakeNotificationSink();
    final runner = AutomaticFollowUpBackgroundRunner(
      taskStore: store,
      notificationSink: sink,
      now: () => now,
    );

    expect(await runner.run(), 1);
    expect(await runner.run(), 0);
    expect(sink.delivered.map((candidate) => candidate.taskId), ['t1']);
  });

  test('failed notification is not marked and is retried', () async {
    final store = _FakeTaskStore([
      Task(
        id: 'retry',
        title: 'پیگیری مجدد',
        followUps: [
          FollowUp(
            id: 'f1',
            dateTime: DateTime(2026, 8, 25),
            nextFollowUp: DateTime(2026, 8, 26, 10),
          ),
        ],
      ),
    ]);
    final sink = _FakeNotificationSink(failuresRemaining: 1);
    final runner = AutomaticFollowUpBackgroundRunner(
      taskStore: store,
      notificationSink: sink,
      now: () => now,
    );

    expect(await runner.run(), 0);
    expect(await runner.run(), 1);
    expect(sink.attempts, 2);
  });

  test('a new latest follow-up schedule can notify after the old one', () async {
    final store = _FakeTaskStore([
      Task(
        id: 'evolving',
        title: 'پرونده در حال تغییر',
        followUps: [
          FollowUp(
            id: 'first',
            dateTime: DateTime(2026, 8, 24),
            nextFollowUp: DateTime(2026, 8, 25),
          ),
        ],
      ),
    ]);
    final sink = _FakeNotificationSink();
    final runner = AutomaticFollowUpBackgroundRunner(
      taskStore: store,
      notificationSink: sink,
      now: () => now,
    );

    expect(await runner.run(), 1);

    store.tasks = [
      Task(
        id: 'evolving',
        title: 'پرونده در حال تغییر',
        followUps: [
          FollowUp(
            id: 'first',
            dateTime: DateTime(2026, 8, 24),
            nextFollowUp: DateTime(2026, 8, 25),
          ),
          FollowUp(
            id: 'second',
            dateTime: DateTime(2026, 8, 26, 9),
            nextFollowUp: DateTime(2026, 8, 26, 11, 30),
          ),
        ],
      ),
    ];

    expect(await runner.run(), 1);
    expect(
      sink.delivered.map((candidate) => candidate.followUpId).toList(),
      ['first', 'second'],
    );
  });

  test('inactive and future tasks do not produce notifications', () async {
    final store = _FakeTaskStore([
      Task(
        id: 'future',
        title: 'آینده',
        followUps: [
          FollowUp(
            id: 'f1',
            dateTime: DateTime(2026, 8, 26, 9),
            nextFollowUp: DateTime(2026, 8, 27),
          ),
        ],
      ),
      Task(
        id: 'done',
        title: 'انجام شده',
        completed: true,
        followUps: [
          FollowUp(
            id: 'f2',
            dateTime: DateTime(2026, 8, 25),
            nextFollowUp: DateTime(2026, 8, 26, 10),
          ),
        ],
      ),
    ]);
    final sink = _FakeNotificationSink();
    final runner = AutomaticFollowUpBackgroundRunner(
      taskStore: store,
      notificationSink: sink,
      now: () => now,
    );

    expect(await runner.run(), 0);
    expect(sink.delivered, isEmpty);
  });
}

class _FakeTaskStore extends TaskStore {
  _FakeTaskStore(this.tasks);

  List<Task> tasks;

  @override
  Future<List<Task>> load() async => List<Task>.of(tasks);
}

class _FakeNotificationSink implements AutomaticFollowUpNotificationSink {
  _FakeNotificationSink({this.failuresRemaining = 0});

  int failuresRemaining;
  int attempts = 0;
  final List<AutomaticFollowUpCandidate> delivered = [];

  @override
  Future<void> showDue(AutomaticFollowUpCandidate candidate) async {
    attempts += 1;
    if (failuresRemaining > 0) {
      failuresRemaining -= 1;
      throw StateError('simulated notification failure');
    }
    delivered.add(candidate);
  }
}
