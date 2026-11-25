import 'dart:async';
import 'dart:collection';

import 'arvin_async_trace.dart';

/// Process-local serialization boundary for canonical TaskStore operations.
///
/// Queued storage I/O runs in the root async Zone so native SQLite work is not
/// coupled to a caller's scheduling Zone (for example, Flutter test FakeAsync).
/// Trace parent and correlation IDs are captured before enqueueing and carried
/// explicitly into the storage operation.
class TaskStorageLock {
  TaskStorageLock._();

  static final Queue<_TaskStorageLockEntry> _queue =
      Queue<_TaskStorageLockEntry>();
  static bool _running = false;

  static Future<T> synchronized<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    final parentOperationId = arvinAsyncTrace.currentOperationId;
    final correlationId = arvinAsyncTrace.currentCorrelationId;

    _queue.add(
      _TaskStorageLockEntry(
        run: () async {
          var actionStarted = false;
          try {
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
          } catch (_) {
            // A diagnostic writer failure must not strand the task lock.
            // If START could not be persisted, execute the original operation
            // without tracing; no false END/SUCCESS event is emitted.
            if (!actionStarted && !completer.isCompleted) {
              try {
                completer.complete(await action());
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
    Zone.root.run(() {
      entry.run().then<void>(
        (_) {
          _running = false;
          _drain();
        },
        onError: (Object _, StackTrace __) {
          _running = false;
          _drain();
        },
      );
    });
  }
}

class _TaskStorageLockEntry {
  const _TaskStorageLockEntry({required this.run});

  final Future<void> Function() run;
}
