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

  await tester.runAsync(() async {
    realAsyncZone = Zone.current;
    started = true;
    await work();
  });

  final zone = realAsyncZone;
  if (zone == null || !started) {
    final exception = tester.takeException();
    if (exception != null) {
      Error.throwWithStackTrace(exception, StackTrace.current);
    }
    throw StateError('WidgetTester.runAsync did not start storage work');
  }

  final cleanupDrained = Completer<void>();
  zone.createTimer(Duration.zero, () {
    if (!cleanupDrained.isCompleted) cleanupDrained.complete();
  });
  await cleanupDrained.future;

  final exception = tester.takeException();
  if (exception != null) {
    Error.throwWithStackTrace(exception, StackTrace.current);
  }
}
