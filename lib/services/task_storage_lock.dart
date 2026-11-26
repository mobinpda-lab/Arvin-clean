import 'dart:async';
import 'dart:collection';

import 'arvin_async_trace.dart';

typedef TaskStorageWorkRunner = Future<void> Function(
  Future<void> Function() work,
);

/// Retains a storage/trace operation failure and a distinct Runner failure.
class TaskStorageLockDualFailure implements Exception {
  const TaskStorageLockDualFailure({
    required this.operationError,
    required this.operationStackTrace,
    required this.runnerError,
    required this.runnerStackTrace,
  });

  final Object operationError;
  final StackTrace operationStackTrace;
  final Object runnerError;
  final StackTrace runnerStackTrace;

  @override
  String toString() =>
      'Storage operation failed: $operationError; Runner failed: $runnerError';
}

/// Process-local serialization boundary for canonical TaskStore operations.
class TaskStorageLock {
  TaskStorageLock._();

  static final Queue<_TaskStorageLockEntry> _queue =
      Queue<_TaskStorageLockEntry>();
  static bool _running = false;
  static TaskStorageWorkRunner _workRunner = _runInCallerZone;
  static ArvinAsyncTrace _trace = arvinAsyncTrace;

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

  /// Injects a trace instance so START/END writer failures can be tested
  /// without mutating the process-wide production trace writer.
  static void setTraceForTesting(ArvinAsyncTrace trace) {
    _trace = trace;
  }

  static void resetTraceForTesting() {
    _trace = arvinAsyncTrace;
  }

  static Future<T> synchronized<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    final zone = Zone.current;
    Object? completionError;
    StackTrace? completionStackTrace;
    late T actionResult;
    var actionStarted = false;
    final runner = _workRunner;
    final trace = _trace;
    final parentOperationId = trace.currentOperationId;
    final correlationId = trace.currentCorrelationId;

    _queue.add(
      _TaskStorageLockEntry(
        zone: zone,
        run: () async {
          Object? traceStartError;
          StackTrace? traceStartStackTrace;
          Object? callbackError;
          StackTrace? callbackStackTrace;
          Object? runnerError;
          StackTrace? runnerStackTrace;
          Object? duplicateInvocationError;
          StackTrace? duplicateInvocationStackTrace;
          Future<void>? callbackFuture;
          var runnerSettled = false;

          Future<void> executeAction() async {
            if (actionStarted) {
              throw StateError('Storage Runner invoked one Action more than once');
            }
            actionStarted = true;
            actionResult = await action();
          }

          Future<void> runTracedAction() async {
            try {
              await trace.run<void>(
                operationName: 'task.storage_lock.owner',
                parentOperationId: parentOperationId,
                correlationId: correlationId,
                operation: executeAction,
              );
            } catch (error, stackTrace) {
              if (actionStarted) {
                // Action, trace END, and trace ERROR failures are terminal.
                // Never execute an action again after it has started.
                Error.throwWithStackTrace(error, stackTrace);
              }

              // Only a failure before Action start can be a trace START
              // failure. Run the fallback inside this same Runner callback;
              // starting a second runAsync here can re-enter the test binding.
              traceStartError = error;
              traceStartStackTrace = stackTrace;
              try {
                await executeAction();
              } catch (actionError, actionStackTrace) {
                Error.throwWithStackTrace(
                  ArvinTraceDualFailure(
                    productError: actionError,
                    productStackTrace: actionStackTrace,
                    writerError: error,
                    writerStackTrace: stackTrace,
                  ),
                  actionStackTrace,
                );
              }
            }
          }

          Future<void> invokeWork() {
            if (runnerSettled || callbackFuture != null) {
              final error = StateError(
                runnerSettled
                    ? 'Storage Runner invoked Action after completing'
                    : 'Storage Runner invoked one Action more than once',
              );
              duplicateInvocationError ??= error;
              duplicateInvocationStackTrace ??= StackTrace.current;
              return Future<void>.error(error, StackTrace.current);
            }
            callbackFuture = runTracedAction();
            return callbackFuture!;
          }

          try {
            try {
              await runner(invokeWork);
            } catch (error, stackTrace) {
              runnerError = error;
              runnerStackTrace = stackTrace;
            } finally {
              runnerSettled = true;
            }

            // Some injected runners return before awaiting the callback they
            // were given. The callback Future is part of the lock contract and
            // must settle before the caller can observe completion.
            final work = callbackFuture;
            if (work != null) {
              try {
                await work;
              } catch (error, stackTrace) {
                callbackError = error;
                callbackStackTrace = stackTrace;
              }
            }

            if (duplicateInvocationError != null && callbackError == null) {
              callbackError = duplicateInvocationError;
              callbackStackTrace = duplicateInvocationStackTrace;
            }

            if (work == null && runnerError == null) {
              callbackError = StateError(
                'Storage Runner completed without invoking Action',
              );
              callbackStackTrace = StackTrace.current;
            }

            if (callbackError != null && runnerError != null &&
                !identical(callbackError, runnerError)) {
              throw TaskStorageLockDualFailure(
                operationError: callbackError,
                operationStackTrace: callbackStackTrace ?? StackTrace.current,
                runnerError: runnerError,
                runnerStackTrace: runnerStackTrace ?? StackTrace.current,
              );
            }
            if (callbackError != null) {
              Error.throwWithStackTrace(
                callbackError,
                callbackStackTrace ?? StackTrace.current,
              );
            }
            if (traceStartError != null && runnerError != null) {
              throw TaskStorageLockDualFailure(
                operationError: traceStartError,
                operationStackTrace: traceStartStackTrace ?? StackTrace.current,
                runnerError: runnerError,
                runnerStackTrace: runnerStackTrace ?? StackTrace.current,
              );
            }
            if (traceStartError != null) {
              Error.throwWithStackTrace(
                traceStartError,
                traceStartStackTrace ?? StackTrace.current,
              );
            }
            if (runnerError != null) {
              Error.throwWithStackTrace(
                runnerError,
                runnerStackTrace ?? StackTrace.current,
              );
            }
          } catch (error, stackTrace) {
            completionError = error;
            completionStackTrace = stackTrace;
          }
        },
        complete: () {
          if (completer.isCompleted) return;
          if (completionError != null) {
            completer.completeError(
              completionError!,
              completionStackTrace ?? StackTrace.current,
            );
          } else if (actionStarted) {
            completer.complete(actionResult);
          } else {
            completer.completeError(
              StateError('Storage Runner completed without executing Action'),
              StackTrace.current,
            );
          }
        },
        fail: (Object error, StackTrace stackTrace) {
          completionError = error;
          completionStackTrace = stackTrace;
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
        // Publish caller completion only after the Runner Future and this
        // queue entry have both fully settled. This prevents cleanup from
        // re-entering a still-owned native async runner.
        _running = false;
        entry.complete();
        _drain();
      },
      onError: (Object error, StackTrace stackTrace) {
        _running = false;
        entry.fail(error, stackTrace);
        entry.complete();
        _drain();
      },
    );
  }
}

class _TaskStorageLockEntry {
  const _TaskStorageLockEntry({
    required this.zone,
    required this.run,
    required this.complete,
    required this.fail,
  });

  final Zone zone;
  final Future<void> Function() run;
  final void Function() complete;
  final void Function(Object error, StackTrace stackTrace) fail;
}
