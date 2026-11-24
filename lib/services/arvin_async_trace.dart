import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

/// A minimal append-only sink for privacy-safe JSONL trace events.
///
/// Implementations must preserve the order in which [writeLine] is awaited.
abstract interface class ArvinJsonlTraceWriter {
  Future<void> writeLine(String line);
  Future<void> flush();
  Future<void> close();
}

/// Writes one JSON object per line to an independent file.
class ArvinFileJsonlTraceWriter implements ArvinJsonlTraceWriter {
  ArvinFileJsonlTraceWriter(this.file);

  final File file;
  IOSink? _sink;
  Future<void> _tail = Future<void>.value();
  bool _closed = false;

  Future<void> _enqueue(Future<void> Function() action) {
    if (_closed) {
      return Future<void>.error(StateError('Trace writer is closed'));
    }
    final next = _tail.then((_) => action());
    // Keep the serialization queue usable after a failed write while still
    // returning that failure to the operation that attempted the write.
    _tail = next.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return next;
  }

  @override
  Future<void> writeLine(String line) => _enqueue(() async {
        _sink ??= file.openWrite(mode: FileMode.append);
        _sink!.writeln(line);
        await _sink!.flush();
      });

  @override
  Future<void> flush() => _enqueue(() async {
        await _sink?.flush();
      });

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    try {
      await _tail;
      await _sink?.flush();
    } finally {
      await _sink?.close();
      _sink = null;
    }
  }
}

/// Retains both failures when product work and diagnostic persistence fail.
class ArvinTraceDualFailure implements Exception {
  const ArvinTraceDualFailure({
    required this.productError,
    required this.productStackTrace,
    required this.writerError,
    required this.writerStackTrace,
  });
  final Object productError;
  final StackTrace productStackTrace;
  final Object writerError;
  final StackTrace writerStackTrace;
  @override
  String toString() => 'Product failed: $productError; trace writer failed: $writerError';
}

/// A single operation that has emitted START but has not emitted a terminal
/// event. This snapshot is intentionally value-free.
class ArvinOpenTraceOperation {
  const ArvinOpenTraceOperation({
    required this.operationId,
    required this.operationName,
    required this.startedAt,
  });

  final String operationId;
  final String operationName;
  final DateTime startedAt;
}

/// Structured asynchronous tracing. Configure an independent writer in tests
/// or diagnostics tooling; the default instance remains developer.log-only
/// until a writer is explicitly attached.
class ArvinAsyncTrace {
  ArvinAsyncTrace({ArvinJsonlTraceWriter? writer}) : _writer = writer;

  static final Object _zoneOperationIdKey = Object();
  static int _idCounter = 0;

  ArvinJsonlTraceWriter? _writer;
  Future<void> _writeTail = Future<void>.value();
  final Map<String, ArvinOpenTraceOperation> _open = {};
  final List<Object> _compatibilityWriterFailures = [];
  bool _closed = false;

  void attachWriter(ArvinJsonlTraceWriter writer) {
    if (_closed) throw StateError('Trace is closed');
    if (_writer != null) throw StateError('A trace writer is already attached');
    _writer = writer;
  }

  List<ArvinOpenTraceOperation> get openOperations =>
      List<ArvinOpenTraceOperation>.unmodifiable(_open.values);

  List<String> get missingEndOperationIds =>
      List<String>.unmodifiable(_open.keys);

  /// Writer failures observed by the already-started Future compatibility
  /// adapter. The adapter preserves the product Future result while exposing
  /// every diagnostic failure here instead of silently discarding it.
  List<Object> get compatibilityWriterFailures =>
      List<Object>.unmodifiable(_compatibilityWriterFailures);

  String _newId(String prefix) {
    _idCounter++;
    return '$prefix-${DateTime.now().toUtc().microsecondsSinceEpoch}-$_idCounter';
  }

  String _sourceLocation() {
    final frames = StackTrace.current.toString().split('\n');
    return frames.firstWhere(
      (frame) => frame.trim().isNotEmpty && !frame.contains('arvin_async_trace.dart'),
      orElse: () => 'unknown',
    ).trim();
  }

  Future<void> _emit(Map<String, Object?> event) async {
    if (_closed) throw StateError('Trace is closed');
    final line = jsonEncode(event);
    final writer = _writer;
    if (writer != null) {
      final next = _writeTail.then((_) => writer.writeLine(line));
      _writeTail =
          next.then<void>((_) {}, onError: (Object _, StackTrace __) {});
      await next;
    }
    // Log only after the independent sink accepted the event. A failed END
    // write must not leave a misleading developer.log success record.
    developer.log(
      '[ARVIN_TRACE] ${event['event_type'] ?? event['event']} ${event['operation_name']}',
      name: 'arvin.async_trace',
      level: event['event'] == 'ERROR' ? 1000 : 800,
    );
  }

  /// Runs [operation] inside an async context. Nested calls automatically
  /// inherit the parent operation ID and correlation ID through Zones.
  Future<T> run<T>({
    required String operationName,
    required Future<T> Function() operation,
    String? parentOperationId,
    String? correlationId,
  }) async {
    if (_closed) throw StateError('Trace is closed');
    final inheritedParent = Zone.current[_zoneOperationIdKey] as String?;
    final operationId = _newId('op');
    final parentId = parentOperationId ?? inheritedParent;
    final resolvedCorrelationId = correlationId ??
        (Zone.current['arvin.trace.correlation'] as String?) ?? _newId('corr');
    final startedAt = DateTime.now().toUtc();
    final stopwatch = Stopwatch()..start();
    final common = <String, Object?>{
      'mission_id': Platform.environment['ARVIN_MISSION_ID'] ?? 'UNSPECIFIED',
      'timestamp_utc': startedAt.toIso8601String(),
      'timestamp': startedAt.toIso8601String(),
      'operation_id': operationId,
      'parent_id': parentId,
      'parent_operation_id': parentId,
      'correlation_id': resolvedCorrelationId,
      'operation_name': operationName,
      'source_location': _sourceLocation(),
    };

    // A failed START prevents product execution. Callers that own an already
    // started Future use traceFuture's compatibility handling below.
    await _emit({
      ...common, 'event_type': 'START', 'event': 'START', 'elapsed_ms': 0,
      'result': 'running', 'status': 'RUNNING', 'exception_type': null,
      'exception_message': null, 'error_type': null,
    });
    _open[operationId] = ArvinOpenTraceOperation(
      operationId: operationId, operationName: operationName, startedAt: startedAt,
    );

    late final T result;
    try {
      result = await runZoned<Future<T>>(
        operation,
        zoneValues: {
          _zoneOperationIdKey: operationId,
          'arvin.trace.correlation': resolvedCorrelationId,
        },
      );
    } catch (productError, productStackTrace) {
      stopwatch.stop();
      try {
        await _emit({
          ...common,
          'timestamp_utc': DateTime.now().toUtc().toIso8601String(),
          'timestamp': DateTime.now().toUtc().toIso8601String(),
          'event_type': 'ERROR', 'event': 'ERROR',
          'elapsed_ms': stopwatch.elapsedMilliseconds,
          'result': 'error', 'status': 'ERROR',
          'exception_type': productError.runtimeType.toString(),
          'exception_message': productError.toString(),
          'error_type': productError.runtimeType.toString(),
        });
        _open.remove(operationId);
      } catch (writerError, writerStackTrace) {
        Error.throwWithStackTrace(
          ArvinTraceDualFailure(
            productError: productError,
            productStackTrace: productStackTrace,
            writerError: writerError,
            writerStackTrace: writerStackTrace,
          ),
          productStackTrace,
        );
      }
      Error.throwWithStackTrace(productError, productStackTrace);
    }

    stopwatch.stop();
    try {
      await _emit({
        ...common,
        'timestamp_utc': DateTime.now().toUtc().toIso8601String(),
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'event_type': 'END', 'event': 'END',
        'elapsed_ms': stopwatch.elapsedMilliseconds,
        'result': 'success', 'status': 'SUCCESS',
        'exception_type': null, 'exception_message': null, 'error_type': null,
      });
      _open.remove(operationId);
    } catch (writerError, writerStackTrace) {
      // Never translate a failed END into success or an ERROR record.
      Error.throwWithStackTrace(writerError, writerStackTrace);
    }
    return result;
  }

  /// Compatibility adapter for existing Future-based call sites.
  ///
  /// The Future argument has already started before it reaches this wrapper.
  /// If the diagnostic writer fails, keep the product operation's original
  /// result/error while leaving the missing terminal trace visible.
  Future<T> traceFuture<T>(String operationName, Future<T> future) async {
    try {
      return await run<T>(
        operationName: operationName,
        operation: () => future,
      );
    } catch (traceError, traceStackTrace) {
      // The Future was supplied already running. Observe it exactly once more
      // (awaiting a Future does not execute it again) so neither its result nor
      // its original failure is lost when START/terminal persistence fails.
      try {
        final result = await future;
        if (traceError is ArvinTraceDualFailure) {
          Error.throwWithStackTrace(traceError, traceStackTrace);
        }
        _compatibilityWriterFailures.add(traceError);
        return result;
      } catch (productError, productStackTrace) {
        if (identical(productError, traceError) ||
            traceError is ArvinTraceDualFailure) {
          Error.throwWithStackTrace(traceError, traceStackTrace);
        }
        Error.throwWithStackTrace(
          ArvinTraceDualFailure(
            productError: productError,
            productStackTrace: productStackTrace,
            writerError: traceError,
            writerStackTrace: traceStackTrace,
          ),
          productStackTrace,
        );
      }
    }
  }

  Future<void> flush() async {
    await _writeTail;
    await _writer?.flush();
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _writeTail;
    await _writer?.flush();
    await _writer?.close();
  }
}

/// The Build trace lane opts in through ARVIN_TRACE_OUTPUT. Normal app runs
/// remain developer.log-only and never create a diagnostic file implicitly.
ArvinJsonlTraceWriter? _traceWriterFromEnvironment() {
  final path = Platform.environment['ARVIN_TRACE_OUTPUT'];
  if (path == null || path.isEmpty) return null;
  return ArvinFileJsonlTraceWriter(File(path));
}

/// Process-wide compatibility facade.
final ArvinAsyncTrace arvinAsyncTrace =
    ArvinAsyncTrace(writer: _traceWriterFromEnvironment());

Future<T> arvinTraceOperation<T>(String stage, Future<T> Function() operation) async {
  var operationStarted = false;
  try {
    return await arvinAsyncTrace.run<T>(operationName: stage, operation: () {
      operationStarted = true;
      return operation();
    });
  } catch (error, stackTrace) {
    if (operationStarted) Error.throwWithStackTrace(error, stackTrace);
    return await operation(); // fallback only when START could not be written
  }
}

Future<T> arvinTraceFutureFactory<T>(String stage, Future<T> Function() createFuture) =>
    arvinTraceOperation<T>(stage, createFuture);

Future<T> arvinTraceFuture<T>(String stage, Future<T> future) =>
    arvinAsyncTrace.traceFuture<T>(stage, future);
