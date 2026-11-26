import 'dart:async';

import 'package:arvin/services/arvin_async_trace.dart';
import 'package:arvin/services/task_storage_lock.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('serializes queued actions in FIFO order', () async {
    final order = <int>[];
    final firstStarted = Completer<void>();
    final releaseFirst = Completer<void>();

    final first = TaskStorageLock.synchronized<void>(() async {
      order.add(1);
      firstStarted.complete();
      await releaseFirst.future;
      order.add(2);
    });
    final second = TaskStorageLock.synchronized<void>(() async {
      order.add(3);
    });

    await firstStarted.future;
    expect(order, [1]);
    releaseFirst.complete();
    await Future.wait([first, second]);
    expect(order, [1, 2, 3]);
  });

  test('propagates action failures and continues draining the queue', () async {
    var secondActionCompleted = false;

    final failed = TaskStorageLock.synchronized<void>(() async {
      throw StateError('expected storage failure');
    });
    final next = TaskStorageLock.synchronized<void>(() async {
      secondActionCompleted = true;
    });

    await expectLater(failed, throwsA(isA<StateError>()));
    await next;
    expect(secondActionCompleted, isTrue);
  });

  test('synchronized completes only after the work runner releases', () async {
    final runnerStarted = Completer<void>();
    final releaseRunner = Completer<void>();
    TaskStorageLock.setWorkRunnerForTesting((work) async {
      runnerStarted.complete();
      await work();
      await releaseRunner.future;
    });
    addTearDown(TaskStorageLock.resetWorkRunnerForTesting);

    final operation = TaskStorageLock.synchronized<int>(() async => 42);
    await runnerStarted.future;

    var completed = false;
    operation.then((_) => completed = true);
    await Future<void>.delayed(Duration.zero);
    expect(completed, isFalse);

    releaseRunner.complete();
    expect(await operation, 42);
  });

  testWidgets(
    'TaskStorageLock isolates native I/O and preserves trace context',
    (tester) async {
        TaskStorageLock.setWorkRunnerForTesting((work) async {
    var started = false;
    await tester.runAsync(() async {
      started = true;
      await work();
    });
    final exception = tester.takeException();
    if (exception != null) {
      Error.throwWithStackTrace(exception, StackTrace.current);
    }
    if (!started) {
      throw StateError('WidgetTester.runAsync did not start storage work');
    }
  });
      addTearDown(TaskStorageLock.resetWorkRunnerForTesting);

      final database = NativeDatabase.memory();
      final completed = Completer<void>();
      Zone? callerZone;
      Zone? storageZone;
      String? parentOperationId;
      String? parentCorrelationId;
      String? storageOperationId;
      String? storageParentOperationId;
      String? storageCorrelationId;

      final operation = arvinAsyncTrace.run<void>(
        operationName: 'task.storage_lock.test_parent',
        operation: () async {
          callerZone = Zone.current;
          parentOperationId = arvinAsyncTrace.currentOperationId;
          parentCorrelationId = arvinAsyncTrace.currentCorrelationId;

          await TaskStorageLock.synchronized<void>(() async {
            storageZone = Zone.current;
            storageOperationId = arvinAsyncTrace.currentOperationId;
            storageParentOperationId =
                arvinAsyncTrace.currentParentOperationId;
            storageCorrelationId = arvinAsyncTrace.currentCorrelationId;

            final rows = await database.runSelect(
              'SELECT 1 AS value',
              const [],
            );
            expect(rows.single['value'], 1);
          });
        },
      );
      operation.then(
        (_) {
          if (!completed.isCompleted) completed.complete();
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!completed.isCompleted) {
            completed.completeError(error, stackTrace);
          }
        },
      );

      try {
        for (var frame = 0;
            !completed.isCompleted && frame < 1200;
            frame++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
        if (!completed.isCompleted) {
          throw TimeoutException(
            'TaskStorageLock did not complete NativeDatabase I/O outside '
            'the caller Zone',
            const Duration(seconds: 20),
          );
        }
        await completed.future;

        expect(storageZone, isNot(same(callerZone)));
        expect(parentOperationId, isNotNull);
        expect(parentCorrelationId, isNotNull);
        expect(storageOperationId, isNotNull);
        expect(storageOperationId, isNot(parentOperationId));
        expect(storageParentOperationId, parentOperationId);
        expect(storageCorrelationId, parentCorrelationId);
      } finally {
        await tester.runAsync(() => database.close());
      }
    },
  );
}
