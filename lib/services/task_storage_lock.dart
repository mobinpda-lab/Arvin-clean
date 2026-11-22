import 'dart:async';
import 'dart:collection';

import 'arvin_async_trace.dart';

/// Process-local serialization boundary for the canonical `arvin.tasks`
/// document.
///
/// SharedPreferences stores the task collection as one JSON value. Without a
/// shared critical section, independent read-modify-write features can race
/// and overwrite newer changes. Every canonical task persistence path should
/// use this lock until the storage implementation is migrated to a
/// transactional database.
class TaskStorageLock {
  TaskStorageLock._();

  static final Queue<_TaskStorageLockEntry> _queue =
      Queue<_TaskStorageLockEntry>();
  static bool _running = false;

  static Future<T> synchronized<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    final zone = Zone.current;

    _queue.add(
      _TaskStorageLockEntry(
        zone: zone,
        run: () async {
          var actionStarted = false;
          try {
            await arvinAsyncTrace.run<void>(
              operationName: 'task.storage_lock.owner',
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
    entry.zone.run(entry.run).whenComplete(() {
      _running = false;
      _drain();
    });
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
