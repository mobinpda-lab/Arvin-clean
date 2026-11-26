import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

/// Runs native asynchronous work through WidgetTester.runAsync and waits for
/// Flutter's own pending-task cleanup callback before releasing the runner.
///
/// AutomatedTestWidgetsFlutterBinding registers its _pendingAsyncTasks cleanup
/// with result.future.whenComplete(). That cleanup is queued in the real async
/// Zone. Awaiting runAsync's returned Future alone can resume before that
/// whenComplete callback has run. Scheduling this sentinel in the captured
/// real async Zone drains that already-queued cleanup microtask first. This is
/// a causal microtask handoff; it does not depend on elapsed time or a Timer.
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
  zone.scheduleMicrotask(() {
    if (!cleanupDrained.isCompleted) cleanupDrained.complete();
  });
  await cleanupDrained.future;

  final exception = tester.takeException();
  if (exception != null) {
    Error.throwWithStackTrace(exception, StackTrace.current);
  }
}
