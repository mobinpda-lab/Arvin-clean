import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/services/arvin_async_trace.dart';

class _MemoryTraceWriter implements ArvinJsonlTraceWriter {
  _MemoryTraceWriter({this.failFromWrite});

  final int? failFromWrite;
  final List<String> lines = [];
  int _writeCount = 0;
  bool flushed = false;
  bool closed = false;

  @override
  Future<void> writeLine(String line) async {
    _writeCount++;
    if (failFromWrite != null && _writeCount == failFromWrite!) {
      throw StateError('injected trace writer failure');
    }
    lines.add(line);
  }

  @override
  Future<void> flush() async {
    flushed = true;
  }

  @override
  Future<void> close() async {
    closed = true;
  }

  List<Map<String, dynamic>> get events => lines
      .map((line) => jsonDecode(line) as Map<String, dynamic>)
      .toList(growable: false);
}

void main() {
  group('ArvinAsyncTrace JSONL', () {
    test('normal completion emits parseable START and END records', () async {
      final writer = _MemoryTraceWriter();
      final trace = ArvinAsyncTrace(writer: writer);

      final value = await trace.run<int>(
        operationName: 'test.normal_completion',
        operation: () async => 42,
      );
      await trace.flush();

      expect(value, 42);
      expect(writer.events.map((event) => event['event']), ['START', 'END']);
      for (final event in writer.events) {
        expect(event.keys, containsAll([
          'timestamp',
          'event',
          'operation_id',
          'parent_operation_id',
          'correlation_id',
          'operation_name',
          'elapsed_ms',
          'status',
          'error_type',
        ]));
        expect(DateTime.tryParse(event['timestamp'] as String), isNotNull);
      }
      expect(writer.events.first['status'], 'RUNNING');
      expect(writer.events.last['status'], 'SUCCESS');
      expect(writer.events.first['operation_id'],
          writer.events.last['operation_id']);
      expect(trace.missingEndOperationIds, isEmpty);
      await trace.close();
      expect(writer.flushed, isTrue);
      expect(writer.closed, isTrue);
    });

    test('exception emits ERROR and rethrows the original exception', () async {
      final writer = _MemoryTraceWriter();
      final trace = ArvinAsyncTrace(writer: writer);

      await expectLater(
        trace.run<void>(
          operationName: 'test.exception',
          operation: () async => throw ArgumentError('safe test failure'),
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(writer.events.map((event) => event['event']), ['START', 'ERROR']);
      expect(writer.events.last['status'], 'ERROR');
      expect(writer.events.last['error_type'], 'ArgumentError');
      expect(writer.events.last['exception_message'], isNull);
      expect(trace.missingEndOperationIds, isEmpty);
      await trace.close();
    });

    test('nested Future records parent and inherited correlation', () async {
      final writer = _MemoryTraceWriter();
      final trace = ArvinAsyncTrace(writer: writer);

      await trace.run<void>(
        operationName: 'test.parent',
        operation: () async {
          await trace.run<void>(
            operationName: 'test.child',
            operation: () async {
              await Future<void>.delayed(Duration.zero);
            },
          );
        },
      );

      final events = writer.events;
      final parentStart = events.firstWhere(
        (event) =>
            event['operation_name'] == 'test.parent' &&
            event['event'] == 'START',
      );
      final childStart = events.firstWhere(
        (event) =>
            event['operation_name'] == 'test.child' &&
            event['event'] == 'START',
      );
      expect(childStart['parent_operation_id'], parentStart['operation_id']);
      expect(childStart['correlation_id'], parentStart['correlation_id']);
      expect(events.where((event) => event['event'] == 'END'), hasLength(2));
      expect(trace.missingEndOperationIds, isEmpty);
      await trace.close();
    });

    test('concurrent operations keep unique IDs and valid JSONL lines',
        () async {
      final writer = _MemoryTraceWriter();
      final trace = ArvinAsyncTrace(writer: writer);

      await Future.wait(List.generate(16, (index) {
        return trace.run<void>(
          operationName: 'test.concurrent.$index',
          operation: () async {
            await Future<void>.delayed(
              Duration(milliseconds: index % 3),
            );
          },
        );
      }));

      final events = writer.events;
      final ids = events
          .where((event) => event['event'] == 'START')
          .map((event) => event['operation_id'])
          .toSet();
      expect(ids, hasLength(16));
      expect(events, hasLength(32));
      expect(events.where((event) => event['event'] == 'END'), hasLength(16));
      expect(trace.missingEndOperationIds, isEmpty);
      await trace.close();
    });

    test('explicit parent and correlation IDs are preserved', () async {
      final writer = _MemoryTraceWriter();
      final trace = ArvinAsyncTrace(writer: writer);

      await trace.run<void>(
        operationName: 'test.explicit_context',
        parentOperationId: 'parent-fixture-1',
        correlationId: 'correlation-fixture-1',
        operation: () async {},
      );

      final start = writer.events.first;
      expect(start['parent_operation_id'], 'parent-fixture-1');
      expect(start['correlation_id'], 'correlation-fixture-1');
      await trace.close();
    });

    test('writer failure is surfaced and never converted to END success',
        () async {
      final writer = _MemoryTraceWriter(failFromWrite: 2);
      final trace = ArvinAsyncTrace(writer: writer);

      await expectLater(
        trace.run<void>(
          operationName: 'test.writer_failure',
          operation: () async {},
        ),
        throwsA(isA<StateError>()),
      );

      final events = writer.events;
      expect(events.map((event) => event['event']), ['START', 'ERROR']);
      expect(events.any((event) => event['status'] == 'SUCCESS'), isFalse);
      expect(trace.missingEndOperationIds, isEmpty);
      await trace.close();
    });

    test('a failed terminal write remains detectable as missing END',
        () async {
      // Fail both terminal events after START has been accepted.
      final trace = ArvinAsyncTrace(writer: _FailTerminalWriter());

      await expectLater(
        trace.run<void>(
          operationName: 'test.missing_end',
          operation: () async {},
        ),
        throwsA(isA<StateError>()),
      );

      expect(trace.missingEndOperationIds, hasLength(1));
      await trace.close();
    });

    test('compatibility Future preserves product result on writer failure',
        () async {
      final writer = _MemoryTraceWriter(failFromWrite: 2);
      final trace = ArvinAsyncTrace(writer: writer);

      final result = await trace.traceFuture<int>(
        'test.compatibility_writer_failure',
        Future<int>.value(73),
      );

      expect(result, 73);
      expect(trace.compatibilityWriterFailures, hasLength(1));
      expect(trace.compatibilityWriterFailures.single, isA<StateError>());
      expect(writer.events.map((event) => event['event']), ['START', 'ERROR']);
      expect(writer.events.any((event) => event['status'] == 'SUCCESS'), isFalse);
      await trace.close();
    });

    test('writes an independent file that parses line by line', () async {
      final configuredPath = Platform.environment['ARVIN_TRACE_OUTPUT'];
      final tempDirectory = configuredPath == null
          ? await Directory.systemTemp.createTemp('arvin-trace-test-')
          : null;
      final file = File(
        configuredPath ?? '${tempDirectory!.path}/arvin-trace.jsonl',
      );
      await file.parent.create(recursive: true);
      if (await file.exists()) await file.delete();

      final trace = ArvinAsyncTrace(
        writer: ArvinFileJsonlTraceWriter(file),
      );
      await trace.run<void>(
        operationName: 'test.file_sink',
        operation: () async {},
      );
      await trace.flush();
      await trace.close();

      final lines = await file.readAsLines();
      expect(lines, hasLength(2));
      final parsed = lines
          .map((line) => jsonDecode(line) as Map<String, dynamic>)
          .toList(growable: false);
      expect(parsed.map((event) => event['event']), ['START', 'END']);
      expect(parsed.every((event) => event['operation_name'] == 'test.file_sink'),
          isTrue);

      if (tempDirectory != null) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('TW-01 preserves product exception identity and original stack', () async {
      final writer = _MemoryTraceWriter();
      final trace = ArvinAsyncTrace(writer: writer);
      final productError = ArgumentError('product identity');
      final productStack = StackTrace.current;
      Object? caught;
      StackTrace? caughtStack;
      try {
        await trace.run<void>(
          operationName: 'tw01',
          operation: () async => Error.throwWithStackTrace(productError, productStack),
        );
      } catch (error, stack) {
        caught = error;
        caughtStack = stack;
      }
      expect(identical(caught, productError), isTrue);
      expect(identical(caughtStack, productStack), isTrue);
      expect(writer.events.map((event) => event['event']), ['START', 'ERROR']);
    });

    test('TW-02 preserves writer exception identity and stack', () async {
      final writerError = StateError('writer identity');
      final writerStack = StackTrace.current;
      final writer = _SpecificFailureWriter(
        failEvent: 'END', error: writerError, stack: writerStack,
      );
      final trace = ArvinAsyncTrace(writer: writer);
      Object? caught;
      StackTrace? caughtStack;
      try {
        await trace.run<void>(
          operationName: 'tw02', operation: () async {},
        );
      } catch (error, stack) {
        caught = error;
        caughtStack = stack;
      }
      expect(identical(caught, writerError), isTrue);
      expect(identical(caughtStack, writerStack), isTrue);
      expect(writer.events, ['START', 'END', 'ERROR']);
    });

    test('TW-03 retains product and writer failures together', () async {
      final productError = ArgumentError('product and writer');
      final productStack = StackTrace.current;
      final writerError = StateError('ERROR write failed');
      final writerStack = StackTrace.current;
      final writer = _SpecificFailureWriter(
        failEvent: 'ERROR', error: writerError, stack: writerStack,
      );
      final trace = ArvinAsyncTrace(writer: writer);
      Object? caught;
      try {
        await trace.run<void>(
          operationName: 'tw03',
          operation: () async => Error.throwWithStackTrace(productError, productStack),
        );
      } catch (error) {
        caught = error;
      }
      expect(caught, isA<ArvinTraceDualFailure>());
      final dual = caught! as ArvinTraceDualFailure;
      expect(identical(dual.productError, productError), isTrue);
      expect(identical(dual.productStackTrace, productStack), isTrue);
      expect(identical(dual.writerError, writerError), isTrue);
      expect(identical(dual.writerStackTrace, writerStack), isTrue);
    });

    test('TW-04 product callback is invoked exactly once after START', () async {
      final writer = _MemoryTraceWriter();
      final trace = ArvinAsyncTrace(writer: writer);
      var calls = 0;
      final result = await trace.run<int>(
        operationName: 'tw04',
        operation: () async { calls++; return 19; },
      );
      expect(result, 19);
      expect(calls, 1);
    });
  });
}

class _SpecificFailureWriter implements ArvinJsonlTraceWriter {
  _SpecificFailureWriter({required this.failEvent, required this.error, required this.stack});
  final String failEvent;
  final Object error;
  final StackTrace stack;
  final List<String> events = [];
  @override
  Future<void> writeLine(String line) async {
    final event = jsonDecode(line) as Map<String, dynamic>;
    final type = event['event'] as String;
    events.add(type);
    if (type == failEvent) Error.throwWithStackTrace(error, stack);
  }
  @override
  Future<void> flush() async {}
  @override
  Future<void> close() async {}
}

class _FailTerminalWriter implements ArvinJsonlTraceWriter {
  @override
  Future<void> writeLine(String line) async {
    final event = jsonDecode(line) as Map<String, dynamic>;
    if (event['event'] == 'START') return;
    throw StateError('injected terminal event failure');
  }

  @override
  Future<void> flush() async {}

  @override
  Future<void> close() async {}
}
