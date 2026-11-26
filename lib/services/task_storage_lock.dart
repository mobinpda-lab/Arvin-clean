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
    final zone = Zone.current;
    final runner = _workRunner;
    final parentOperationId = arvinAsyncTrace.currentOperationId;
    final correlationId = arvinAsyncTrace.currentCorrelationId;

    _queue.add(
      _TaskStorageLockEntry(
        zone: zone,
        run: () async {
          var actionStarted = false;
          late T actionResult;
          Object? operationError;
          StackTrace? operationStackTrace;

          Future<void> executeAction() async {
            if (actionStarted) {
              throw StateError('Storage Runner invoked one Action more than once');
            }
            actionStarted = true;
            actionResult = await action();
          }

          try {
            try {
              await runner(() async {
                await arvinAsyncTrace.run<void>(
                  operationName: 'task.storage_lock.owner',
                  parentOperationId: parentOperationId,
                  correlationId: correlationId,
                  operation: executeAction,
                );
              });
            } catch (traceOrRunnerError, traceOrRunnerStack) {
              if (!actionStarted) {
                // A failed trace START must not strand the queue. Retry the
                // Action once without tracing, still under the same Runner.
                try {
                  await runner(executeAction);
                } catch (fallbackError, fallbackStack) {
                  operationError = fallbackError;
                  operationStackTrace = fallbackStack;
                }
              } else {
                // Includes Action, trace END, and Runner-release failures.
                // Do not hide failures merely because product work returned.
                operationError = traceOrRunnerError;
                operationStackTrace = traceOrRunnerStack;
              }
            }
          } finally {
            // Publish the result only after the Runner has actually returned.
            // Thus completion also propagates failures from trace END and from
            // the Runner's post-work release path.
            if (!completer.isCompleted) {
              if (operationError != null) {
                completer.completeError(
                  operationError,
                  operationStackTrace ?? StackTrace.current,
                );
              } else if (actionStarted) {
                completer.complete(actionResult);
              } else {
                completer.completeError(
                  StateError('Storage Runner completed without executing Action'),
                  StackTrace.current,
                );
              }
            }
          }
        },
      ),
    );
    _drain();
    return completer.future;
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
