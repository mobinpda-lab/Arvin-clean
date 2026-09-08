import 'dart:async';

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

  static Future<void> _tail = Future<void>.value();

  static Future<T> synchronized<T>(Future<T> Function() action) {
    final completer = Completer<T>();

    _tail = _tail.then((_) async {
      try {
        completer.complete(await action());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });

    // Keep the queue alive even when one operation fails.
    _tail = _tail.catchError((_) {});
    return completer.future;
  }
}
