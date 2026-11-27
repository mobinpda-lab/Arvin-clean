import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

/// Runs native asynchronous work through WidgetTester.runAsync and waits for
/// Flutter's own pending-task cleanup callback before releasing the runner.
///
/// AutomatedTestWidgetsFlutterBinding registers its _pendingAsyncTasks cleanup
/// with result.future.whenComplete(). The callback Future can resume the caller
/// before that cleanup microtask has drained. A zero-duration Timer scheduled
/// in the captured real async Zone runs after its queued microtasks, providing
/// an event-loop barrier without sleeping or increasing any test timeout.
Future<void> runFlutterAsyncWithCleanupHandshake(
  WidgetTester tester,
  Future<void> Function() work,
) async {
  Zone? realAsyncZone;
  var started = false;

  print('[ARVIN_ASYNC_HANDSHAKE] phase=run_async_enter');
  try {
    await tester.runAsync(() async {
      realAsyncZone = Zone.current;
      started = true;
      print('[ARVIN_ASYNC_HANDSHAKE] phase=callback_enter');
      try {
        print('[ARVIN_ASYNC_HANDSHAKE] phase=work_enter');
        await work();
        print('[ARVIN_ASYNC_HANDSHAKE] phase=work_complete');
      } catch (error, stackTrace) {
        print('[ARVIN_ASYNC_HANDSHAKE] phase=work_error error=$error');
        Error.throwWithStackTrace(error, stackTrace);
      }
    });
    print('[ARVIN_ASYNC_HANDSHAKE] phase=run_async_return');
  } catch (error, stackTrace) {
    print('[ARVIN_ASYNC_HANDSHAKE] phase=run_async_error error=$error');
    Error.throwWithStackTrace(error, stackTrace);
  }

  final zone = realAsyncZone;
  if (zone == null || !started) {
    final exception = tester.takeException();
    if (exception != null) {
      Error.throwWithStackTrace(exception, StackTrace.current);
    }
    throw StateError('WidgetTester.runAsync did not start storage work');
  }

  final cleanupDrained = Completer<void>();
  print('[ARVIN_ASYNC_HANDSHAKE] phase=cleanup_barrier_scheduled');
  zone.createTimer(Duration.zero, () {
    print('[ARVIN_ASYNC_HANDSHAKE] phase=cleanup_barrier_fired');
    if (!cleanupDrained.isCompleted) cleanupDrained.complete();
  });
  await cleanupDrained.future;
  print('[ARVIN_ASYNC_HANDSHAKE] phase=cleanup_barrier_complete');

  final exception = tester.takeException();
  if (exception != null) {
    Error.throwWithStackTrace(exception, StackTrace.current);
  }
}
