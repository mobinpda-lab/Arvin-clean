import 'dart:async';

/// Temporary, value-free async tracing for MASTER EXECUTION 170-R.
/// Emits only stage names, elapsed time, and exception types.
Future<T> arvinTraceFuture<T>(String stage, Future<T> future) async {
  final stopwatch = Stopwatch()..start();
  print('[ARVIN_TRACE] START $stage');
  try {
    final value = await future;
    print('[ARVIN_TRACE] END $stage ${stopwatch.elapsedMilliseconds}ms');
    return value;
  } catch (error) {
    print('[ARVIN_TRACE] ERROR $stage ${stopwatch.elapsedMilliseconds}ms ${error.runtimeType}');
    rethrow;
  }
}
