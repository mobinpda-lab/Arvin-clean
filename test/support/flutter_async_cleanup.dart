import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_test/flutter_test.dart';

/// Runs native asynchronous work through WidgetTester.runAsync and waits for
/// Flutter's pending-task cleanup before releasing the storage runner.
///
/// The real-zone event barrier lets the runAsync callback's queued microtasks
/// drain. A zero-duration WidgetTester pump then drains the test binding's
/// FakeAsync microtasks before a subsequent operation can call runAsync again.
Future<void> runFlutterAsyncWithCleanupHandshake(
  WidgetTester tester,
  Future<void> Function() work,
) async {
  Zone? realAsyncZone;
  var started = false;

  developer.log('phase=run_async_enter', name: 'arvin.async_cleanup');
  try {
    await tester.runAsync(() async {
      realAsyncZone = Zone.current;
      started = true;
      developer.log('phase=callback_enter', name: 'arvin.async_cleanup');
      try {
        developer.log('phase=work_enter', name: 'arvin.async_cleanup');
        await work();
        developer.log('phase=work_complete', name: 'arvin.async_cleanup');
      } catch (error, stackTrace) {
        developer.log(
          'phase=work_error error=$error',
          name: 'arvin.async_cleanup',
          error: error,
          stackTrace: stackTrace,
        );
        Error.throwWithStackTrace(error, stackTrace);
      }
    });
    developer.log('phase=run_async_return', name: 'arvin.async_cleanup');
  } catch (error, stackTrace) {
    developer.log(
      'phase=run_async_error error=$error',
      name: 'arvin.async_cleanup',
      error: error,
      stackTrace: stackTrace,
    );
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
  developer.log('phase=cleanup_barrier_scheduled', name: 'arvin.async_cleanup');
  zone.createTimer(Duration.zero, () {
    developer.log('phase=cleanup_barrier_fired', name: 'arvin.async_cleanup');
    if (!cleanupDrained.isCompleted) cleanupDrained.complete();
  });
  await cleanupDrained.future;
  developer.log('phase=cleanup_barrier_complete', name: 'arvin.async_cleanup');

  // The runAsync callback runs in a real async Zone, while the test body
  // resumes in FakeAsync. Pump once so binding cleanup microtasks queued in
  // FakeAsync are drained before this helper permits another runAsync call.
  await tester.pump();
  developer.log('phase=fake_async_cleanup_complete', name: 'arvin.async_cleanup');

  final exception = tester.takeException();
  if (exception != null) {
    Error.throwWithStackTrace(exception, StackTrace.current);
  }
}
