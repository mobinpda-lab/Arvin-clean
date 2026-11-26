import 'dart:async';
import 'dart:collection';

import 'arvin_async_trace.dart';

typedef TaskStorageWorkRunner = Future<void> Function(
  Future<void> Function() work,
);

/// Process-local serialization boundary for canonical TaskStore operations.
class TaskStorageLock {
  TaskStorageLock._();

  static final Queue<_TaskStorageLockEntry> _queue =
      Queue<_TaskStorageLockEntry>();
  static bool _running = false;
  static TaskStorageWorkRunner _workRunner = _runInCallerZone;

  static Future<void> _runInCallerZone(Future<void> Function() work) => work();

  /// Overrides storage execution for widget tests using Flutter FakeAsync.
  ///
  /// Production callers keep the default caller-Zone behavior.
  static void setWorkRunnerForTesting(TaskStorageWorkRunner runner) {
    _workRunner = runner;
  }

  static void resetWorkRunnerForTesting() {
    _workRunner = _runInCallerZone;
  }

  static Future<T> synchronized<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    final entryFinished = Completer<void>();
    final zone = Zone.current;
    final runner = _workRunner;
    final parentOperationId = arvinAsyncTrace.currentOperationId;
    final correlationId = arvinAsyncTrace.currentCorrelationId;

    _queue.add(
      _TaskStorageLockEntry(
        zone: zone,
        run: () async {
          try {
            var actionStarted = false;
            try {
              await runner(() async {
                await arvinAsyncTrace.run<void>(
                  operationName: 'task.storage_lock.owner',
                  parentOperationId: parentOperationId,
                  correlationId: correlationId,
                  operation: () async {
                    actionStarted = true;
                    try {
                      completer.complete(await action());
                    } catch (error, stackTrace) {
                      completer.completeError(error, stackTrace);
                      Error.throwWithStackTrace(error, stackTrace);
                    }
                  },
                );
              });
            } catch (traceError, traceStack) {
              if (!actionStarted && !completer.isCompleted) {
                // A diagnostic START failure must not strand the storage queue.
                // If product work has not started, run it once without tracing.
                try {
                  await runner(() async {
                    try {
                      completer.complete(await action());
                    } catch (error, stackTrace) {
                      completer.completeError(error, stackTrace);
                      Error.throwWithStackTrace(error, stackTrace);
                    }
                  });
                } catch (error, stackTrace) {
                  if (!completer.isCompleted) {
                    completer.completeError(error, stackTrace);
                  }
                }
              } else if (!completer.isCompleted) {
                completer.completeError(traceError, traceStack);
              }
            }
          } finally {
            // The action result can be ready before the runner has released
            // its async boundary. Do not report synchronized() complete until
            // that runner has finished, otherwise a following tester.runAsync
            // can overlap the still-active storage operation.
            if (!entryFinished.isCompleted) entryFinished.complete();
          }
        },
      ),
    );
    _drain();

    // Keep the result/error contract, but make completion mean that the
    // serialized runner has also finished and released its async boundary.
    return _completeAfterEntry<T>(completer.future, entryFinished.future);
  }

  static Future<T> _completeAfterEntry<T>(
    Future<T> result,
    Future<void> entryFinished,
  ) async {
    try {
      final value = await result;
      await entryFinished;
      return value;
    } catch (error, stackTrace) {
      await entryFinished;
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  static void _drain() {
    if (_running || _queue.isEmpty) return;

    _running = true;
    final entry = _queue.removeFirst();
    entry.zone.run(entry.run).then<void>(
      (_) {
        _running = false;
        _drain();
      },
      onError: (Object _, StackTrace __) {
        _running = false;
        _drain();
      },
    );
  }
}

class _TaskStorageLockEntry {
  const _TaskStorageLockEntry({
    required this.zone,
    required this.run,
  });

  final Zone zone;
  final Future<void> Function() run;
}
