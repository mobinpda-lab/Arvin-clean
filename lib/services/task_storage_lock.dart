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
          final actionResult = Completer<T>();
          try {
            await arvinAsyncTrace.run<void>(
              operationName: 'task.storage_lock.owner',
              parentOperationId: parentOperationId,
              correlationId: correlationId,
              operation: () async {
                await runner(() async {
                  actionStarted = true;
                  try {
                    actionResult.complete(await action());
                  } catch (error, stackTrace) {
                    actionResult.completeError(error, stackTrace);
                    Error.throwWithStackTrace(error, stackTrace);
                  }
                });
                try {
                  completer.complete(await actionResult.future);
                } catch (error, stackTrace) {
                  completer.completeError(error, stackTrace);
                  Error.throwWithStackTrace(error, stackTrace);
                }
              },
            );
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
              if (actionResult.isCompleted) {
                try {
                  completer.complete(await actionResult.future);
                } catch (error, stackTrace) {
                  completer.completeError(error, stackTrace);
                }
              } else {
                completer.completeError(traceError, traceStack);
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
