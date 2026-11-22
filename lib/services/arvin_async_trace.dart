import 'dart:async';
import 'dart:developer' as developer;

/// Temporary, value-free async tracing for MASTER EXECUTION 172-R.
/// Emits only stage names, elapsed time, and exception types.
/// Never pass Task content, credentials, passphrases, or database rows here.
Future<T> arvinTraceFuture<T>(String stage, Future<T> future) async {
  final stopwatch = Stopwatch()..start();
  developer.log('[ARVIN_TRACE] START $stage', name: 'arvin.async_trace');
  try {
    final value = await future;
    developer.log(
      '[ARVIN_TRACE] END $stage ${stopwatch.elapsedMilliseconds}ms',
      name: 'arvin.async_trace',
    );
    return value;
  } catch (error) {
    developer.log(
      '[ARVIN_TRACE] ERROR $stage ${stopwatch.elapsedMilliseconds}ms ${error.runtimeType}',
      name: 'arvin.async_trace',
      level: 1000,
    );
    rethrow;
  }
}
