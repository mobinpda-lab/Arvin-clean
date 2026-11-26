import 'dart:async';
import 'dart:convert';

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

  test('fails when Runner exits before invoking Action', () async {
    final runnerError = StateError('runner failed before callback');
    final runnerStack = StackTrace.current;
    var actionCount = 0;
    TaskStorageLock.setWorkRunnerForTesting((_) async {
      Error.throwWithStackTrace(runnerError, runnerStack);
    });
    addTearDown(TaskStorageLock.resetWorkRunnerForTesting);

    Object? caught;
    StackTrace? caughtStack;
    try {
      await TaskStorageLock.synchronized<void>(() async {
        actionCount += 1;
      });
    } catch (error, stackTrace) {
      caught = error;
      caughtStack = stackTrace;
    }

    expect(identical(caught, runnerError), isTrue);
    expect(identical(caughtStack, runnerStack), isTrue);
    expect(actionCount, 0);
  });

  test('Trace START fallback succeeds but original writer failure remains visible',
      () async {
    final startError = StateError('trace START failed');
    final startStack = StackTrace.current;
    final writer = _FailingTraceWriter(
      failEvent: 'START',
      error: startError,
      stackTrace: startStack,
    );
    TaskStorageLock.setTraceForTesting(ArvinAsyncTrace(writer: writer));
    addTearDown(TaskStorageLock.resetTraceForTesting);

    var runnerCount = 0;
    var actionCount = 0;
    TaskStorageLock.setWorkRunnerForTesting((work) async {
      runnerCount += 1;
      await work();
    });
    addTearDown(TaskStorageLock.resetWorkRunnerForTesting);

    Object? caught;
    StackTrace? caughtStack;
    try {
      await TaskStorageLock.synchronized<void>(() async {
        actionCount += 1;
      });
    } catch (error, stackTrace) {
      caught = error;
      caughtStack = stackTrace;
    }

    expect(runnerCount, 1);
    expect(actionCount, 1);
    expect(identical(caught, startError), isTrue);
    expect(identical(caughtStack, startStack), isTrue);
    expect(writer.events, ['START']);
  });

  test('awaits the callback Future even when Runner does not await it', () async {
    final actionStarted = Completer<void>();
    final releaseAction = Completer<void>();
    TaskStorageLock.setWorkRunnerForTesting((work) async {
      unawaited(work());
    });
    addTearDown(TaskStorageLock.resetWorkRunnerForTesting);

    final operation = TaskStorageLock.synchronized<void>(() async {
      actionStarted.complete();
      await releaseAction.future;
    });
    await actionStarted.future;

    var completed = false;
    operation.then((_) => completed = true);
    await Future<void>.delayed(Duration.zero);
    expect(completed, isFalse);

    releaseAction.complete();
    await operation;
    expect(completed, isTrue);
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

  test('propagates Runner release failure without repeating the Action', () async {
    var actionCount = 0;
    TaskStorageLock.setWorkRunnerForTesting((work) async {
      await work();
      throw StateError('runner release failed');
    });
    addTearDown(TaskStorageLock.resetWorkRunnerForTesting);

    final operation = TaskStorageLock.synchronized<void>(() async {
      actionCount += 1;
    });

    await expectLater(operation, throwsA(isA<StateError>()));
    expect(actionCount, 1);
  });

  test('does not repeat Action when Trace END fails', () async {
    final endError = StateError('trace END failed');
    final endStack = StackTrace.current;
    final writer = _FailingTraceWriter(
      failEvent: 'END',
      error: endError,
      stackTrace: endStack,
    );
    TaskStorageLock.setTraceForTesting(ArvinAsyncTrace(writer: writer));
    addTearDown(TaskStorageLock.resetTraceForTesting);

    var actionCount = 0;
    Object? caught;
    StackTrace? caughtStack;
    try {
      await TaskStorageLock.synchronized<void>(() async {
        actionCount += 1;
      });
    } catch (error, stackTrace) {
      caught = error;
      caughtStack = stackTrace;
    }

    expect(actionCount, 1);
    expect(identical(caught, endError), isTrue);
    expect(identical(caughtStack, endStack), isTrue);
    expect(writer.events, ['START', 'END', 'ERROR']);
  });

  test('executes an Action at most once if a Runner invokes its callback twice',
      () async {
    var actionCount = 0;
    TaskStorageLock.setWorkRunnerForTesting((work) async {
      await work();
      await work();
    });
    addTearDown(TaskStorageLock.resetWorkRunnerForTesting);

    final operation = TaskStorageLock.synchronized<void>(() async {
      actionCount += 1;
    });

    await expectLater(operation, throwsA(isA<StateError>()));
    expect(actionCount, 1);
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

class _FailingTraceWriter implements ArvinJsonlTraceWriter {
  _FailingTraceWriter({
    required this.failEvent,
    required this.error,
    required this.stackTrace,
  });

  final String failEvent;
  final Object error;
  final StackTrace stackTrace;
  final List<String> events = [];

  @override
  Future<void> writeLine(String line) async {
    final event = jsonDecode(line) as Map<String, dynamic>;
    final type = event['event'] as String;
    events.add(type);
    if (type == failEvent) {
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  @override
  Future<void> flush() async {}

  @override
  Future<void> close() async {}
}
