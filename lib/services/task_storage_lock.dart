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

  /// Overrides the execution runner for widget tests that use FakeAsync.
  ///
  /// Production callers retain their current Zone unless a test explicitly
  /// installs a real-async runner.
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
          } catch (_) {
            // A diagnostic START failure must not strand the storage queue.
            // If product work has not started, run it once without tracing.
            if (!actionStarted && !completer.isCompleted) {
              try {
                await runner(() async {
                  completer.complete(await action());
                });
              } catch (error, stackTrace) {
                completer.completeError(error, stackTrace);
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
