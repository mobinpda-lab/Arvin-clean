import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs native asynchronous work through WidgetTester.runAsync and lets the
/// real async Zone drain before the test binding's FakeAsync cleanup pump.
///
/// The real-zone event turn is awaited inside the runAsync callback. Awaiting a
/// Completer created by FakeAsync after the callback returns can deadlock:
/// completing it from a real Zone still schedules the awaiting continuation
/// into FakeAsync, which cannot advance until the test pumps.
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
  var started = false;

  try {
    await tester.runAsync(() async {
      started = true;
      logPhase('callback_enter');
      try {
        logPhase('work_enter');
        await work();
        logPhase('work_complete');
        // Yield on the real event loop before runAsync returns. This drains
        // work queued by native I/O without awaiting a FakeAsync-owned Future.
        await Future<void>.delayed(Duration.zero);
        logPhase('real_async_turn_complete');
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

  if (!started) {
    final exception = tester.takeException();
    if (exception != null) {
      Error.throwWithStackTrace(exception, StackTrace.current);
    }
    throw StateError('WidgetTester.runAsync did not start storage work');
  }

  // runAsync has now returned to FakeAsync. Pump its pending cleanup
  // microtasks before allowing the next native operation to start.
  logPhase('fake_async_pump_start');
  await tester.pump();
  logPhase('fake_async_cleanup_complete');

  final exception = tester.takeException();
  if (exception != null) {
    logPhase('binding_exception type=${exception.runtimeType} error=$exception');
    Error.throwWithStackTrace(exception, StackTrace.current);
  }
}
