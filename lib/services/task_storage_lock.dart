import 'dart:async';
import 'dart:collection';

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

  /// Test-only diagnostic switch; does not alter queue or serialization behavior.
  static bool diagnosticLoggingEnabled = false;

  static Future<T> synchronized<T>(Future<T> Function() action) {
    if (diagnosticLoggingEnabled) {
      print('[ARVIN_TIMEOUT_DIAG][LOCK] queued; pending=${_queue.length + 1}; running=$_running');
    }
    final completer = Completer<T>();
    final zone = Zone.current;

    _queue.add(
      _TaskStorageLockEntry(
        zone: zone,
        run: () async {
          if (diagnosticLoggingEnabled) print('[ARVIN_TIMEOUT_DIAG][LOCK] acquired; pending=${_queue.length}');
          try {
            final result = await action();
            if (diagnosticLoggingEnabled) print('[ARVIN_TIMEOUT_DIAG][LOCK] action completed');
            completer.complete(result);
          } catch (error, stackTrace) {
            if (diagnosticLoggingEnabled) print('[ARVIN_TIMEOUT_DIAG][LOCK] action failed: $error');
            completer.completeError(error, stackTrace);
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
      if (diagnosticLoggingEnabled) print('[ARVIN_TIMEOUT_DIAG][LOCK] released');
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
