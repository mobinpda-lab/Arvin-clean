import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs native asynchronous work through WidgetTester.runAsync and waits for
/// Flutter's pending-task cleanup before releasing the storage runner.
///
/// The real-zone event barrier lets the runAsync callback's queued microtasks
/// drain. A zero-duration WidgetTester pump then drains the test binding's
/// FakeAsync microtasks before a subsequent operation can call runAsync again.
var _cleanupRunSequence = 0;

/// Awaits work completed by a real async Zone while the test body is in
/// FakeAsync. The watchdog uses Zone.root so its duration is wall-clock time,
/// not simulated frames. This preserves a bounded wait without starving
/// native I/O by rapidly pumping fake frames.
Future<T> waitForRealAsync<T>(
  Future<T> future, {
  required Duration timeout,
  required String operation,
}) async {
  final completion = Completer<T>();
  final timer = Zone.root.createTimer(timeout, () {
    if (!completion.isCompleted) {
      completion.completeError(TimeoutException(
        '$operation did not complete within $timeout',
        timeout,
      ));
    }
  });
  future.then(
    (value) {
      if (!completion.isCompleted) completion.complete(value);
    },
    onError: (Object error, StackTrace stackTrace) {
      if (!completion.isCompleted) {
        completion.completeError(error, stackTrace);
      }
    },
  );
  try {
    return await completion.future;
  } finally {
    timer.cancel();
  }
}

Future<void> runFlutterAsyncWithCleanupHandshake(
  WidgetTester tester,
  Future<void> Function() work,
) async {
  final runId = ++_cleanupRunSequence;
  void logPhase(String phase) =>
      debugPrintSynchronously('ARVIN_ASYNC_CLEANUP[$runId] $phase');

  logPhase('run_async_enter');
  Zone? realAsyncZone;
  var started = false;

  try {
    await tester.runAsync(() async {
      realAsyncZone = Zone.current;
      started = true;
      logPhase('callback_enter');
      try {
        logPhase('work_enter');
        await work();
        logPhase('work_complete');
      } catch (error, stackTrace) {
        logPhase('work_error type=${error.runtimeType} error=$error');
        Error.throwWithStackTrace(error, stackTrace);
      }
    });
    logPhase('run_async_return');
  } catch (error, stackTrace) {
    logPhase('run_async_error type=${error.runtimeType} error=$error');
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
  logPhase('cleanup_barrier_scheduled');
  zone.createTimer(Duration.zero, () {
    logPhase('cleanup_barrier_fired');
    if (!cleanupDrained.isCompleted) cleanupDrained.complete();
  });
  await cleanupDrained.future;
  logPhase('cleanup_barrier_complete');

  // The runAsync callback runs in a real async Zone, while the test body
  // resumes in FakeAsync. Pump once so binding cleanup microtasks queued in
  // FakeAsync are drained before this helper permits another runAsync call.
  logPhase('fake_async_pump_start');
  await tester.pump();
  logPhase('fake_async_cleanup_complete');

  final exception = tester.takeException();
  if (exception != null) {
    logPhase('binding_exception type=${exception.runtimeType} error=$exception');
    Error.throwWithStackTrace(exception, StackTrace.current);
  }
}
