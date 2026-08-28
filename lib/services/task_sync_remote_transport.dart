import 'dart:collection';

import '../models/task.dart';

class RemoteTaskSyncSnapshot {
  RemoteTaskSyncSnapshot({
    required this.generation,
    required Iterable<Task> tasks,
    Map<String, String> ancestorFingerprints = const {},
    this.formatVersion = 1,
  })  : tasks = List<Task>.unmodifiable(tasks),
        ancestorFingerprints = Map<String, String>.unmodifiable(
          ancestorFingerprints,
        ) {
    if (formatVersion != 1) {
      throw ArgumentError.value(formatVersion, 'formatVersion');
    }
    if (generation.trim().isEmpty) {
      throw ArgumentError.value(generation, 'generation');
    }
    final ids = <String>{};
    for (final task in this.tasks) {
      if (task.id.trim().isEmpty || !ids.add(task.id)) {
        throw ArgumentError('Remote snapshot has an empty or duplicate Task id.');
      }
    }
    for (final entry in this.ancestorFingerprints.entries) {
      if (entry.key.trim().isEmpty || entry.value.trim().isEmpty) {
        throw ArgumentError('Ancestor fingerprint keys/values must not be empty.');
      }
      if (!ids.contains(entry.key)) {
        throw ArgumentError(
          'Ancestor fingerprint targets a Task absent from the snapshot: ${entry.key}',
        );
      }
    }
  }

  final int formatVersion;
  final String generation;
  final List<Task> tasks;
  final Map<String, String> ancestorFingerprints;

  Map<String, Object> toJson() => <String, Object>{
        'formatVersion': formatVersion,
        'generation': generation,
        'tasks': tasks.map((task) => task.toJson()).toList(growable: false),
        'ancestorFingerprints': ancestorFingerprints,
      };

  factory RemoteTaskSyncSnapshot.fromJson(Map<String, dynamic> json) {
    final formatVersion = json['formatVersion'];
    final generation = json['generation'];
    final rawTasks = json['tasks'];
    final rawAncestors = json['ancestorFingerprints'];
    if (formatVersion is! int || generation is! String || rawTasks is! List) {
      throw const FormatException('Malformed remote Task sync snapshot.');
    }
    if (rawAncestors != null && rawAncestors is! Map) {
      throw const FormatException('Malformed ancestor fingerprint map.');
    }

    final tasks = <Task>[];
    for (final raw in rawTasks) {
      if (raw is! Map) {
        throw const FormatException('Malformed Task in remote sync snapshot.');
      }
      tasks.add(Task.fromJson(Map<String, dynamic>.from(raw)));
    }

    final ancestors = <String, String>{};
    if (rawAncestors is Map) {
      for (final entry in rawAncestors.entries) {
        if (entry.key is! String || entry.value is! String) {
          throw const FormatException('Malformed ancestor fingerprint entry.');
        }
        ancestors[entry.key as String] = entry.value as String;
      }
    }

    return RemoteTaskSyncSnapshot(
      formatVersion: formatVersion,
      generation: generation,
      tasks: tasks,
      ancestorFingerprints: ancestors,
    );
  }
}

class TaskSyncRemoteWriteResult {
  const TaskSyncRemoteWriteResult({
    required this.generation,
    required this.applied,
  });

  final String generation;
  final bool applied;
}

/// Provider-neutral remote state boundary for multi-device Task sync.
///
/// Implementations must treat [expectedGeneration] as an optimistic
/// compare-and-swap precondition and [operationId] as an idempotency identity.
/// A stale precondition must fail rather than silently overwrite remote state.
abstract interface class TaskSyncRemoteTransport {
  Future<RemoteTaskSyncSnapshot> fetch();

  Future<TaskSyncRemoteWriteResult> compareAndSwap({
    required RemoteTaskSyncSnapshot snapshot,
    required String expectedGeneration,
    required String operationId,
  });
}

class TaskSyncRetryEnvelope {
  TaskSyncRetryEnvelope({
    required this.operationId,
    required this.expectedGeneration,
    required this.snapshot,
    this.attempt = 0,
  }) {
    if (operationId.trim().isEmpty || expectedGeneration.trim().isEmpty) {
      throw ArgumentError('Retry identity and expected generation are required.');
    }
    if (attempt < 0) {
      throw ArgumentError.value(attempt, 'attempt');
    }
  }

  final String operationId;
  final String expectedGeneration;
  final RemoteTaskSyncSnapshot snapshot;
  final int attempt;

  TaskSyncRetryEnvelope nextAttempt() => TaskSyncRetryEnvelope(
        operationId: operationId,
        expectedGeneration: expectedGeneration,
        snapshot: snapshot,
        attempt: attempt + 1,
      );
}

class TaskSyncRemoteConflict implements Exception {
  const TaskSyncRemoteConflict({
    required this.expectedGeneration,
    required this.actualGeneration,
  });

  final String expectedGeneration;
  final String actualGeneration;

  @override
  String toString() =>
      'TaskSyncRemoteConflict(expected: $expectedGeneration, actual: $actualGeneration)';
}

class TaskSyncRemoteUnavailable implements Exception {
  const TaskSyncRemoteUnavailable([this.message = 'Remote sync transport unavailable.']);

  final String message;

  @override
  String toString() => 'TaskSyncRemoteUnavailable($message)';
}

/// Small in-memory reference transport used by focused contract tests and
/// higher-level orchestration tests. Production providers must implement the
/// same compare-and-swap/idempotency semantics.
class InMemoryTaskSyncRemoteTransport implements TaskSyncRemoteTransport {
  InMemoryTaskSyncRemoteTransport(RemoteTaskSyncSnapshot initial)
      : _snapshot = initial;

  RemoteTaskSyncSnapshot _snapshot;
  bool available = true;
  final Set<String> _appliedOperationIds = <String>{};
  final Map<String, String> _operationGenerations = <String, String>{};

  UnmodifiableSetView<String> get appliedOperationIds =>
      UnmodifiableSetView<String>(_appliedOperationIds);

  @override
  Future<RemoteTaskSyncSnapshot> fetch() async {
    _requireAvailable();
    return _snapshot;
  }

  @override
  Future<TaskSyncRemoteWriteResult> compareAndSwap({
    required RemoteTaskSyncSnapshot snapshot,
    required String expectedGeneration,
    required String operationId,
  }) async {
    _requireAvailable();
    if (operationId.trim().isEmpty || expectedGeneration.trim().isEmpty) {
      throw ArgumentError('operationId and expectedGeneration are required.');
    }

    final priorGeneration = _operationGenerations[operationId];
    if (priorGeneration != null) {
      return TaskSyncRemoteWriteResult(
        generation: priorGeneration,
        applied: false,
      );
    }

    if (_snapshot.generation != expectedGeneration) {
      throw TaskSyncRemoteConflict(
        expectedGeneration: expectedGeneration,
        actualGeneration: _snapshot.generation,
      );
    }

    final nextGeneration = _nextGeneration(_snapshot.generation);
    _snapshot = RemoteTaskSyncSnapshot(
      generation: nextGeneration,
      tasks: snapshot.tasks,
      ancestorFingerprints: snapshot.ancestorFingerprints,
    );
    _appliedOperationIds.add(operationId);
    _operationGenerations[operationId] = nextGeneration;
    return TaskSyncRemoteWriteResult(
      generation: nextGeneration,
      applied: true,
    );
  }

  void _requireAvailable() {
    if (!available) throw const TaskSyncRemoteUnavailable();
  }

  String _nextGeneration(String current) {
    final numeric = int.tryParse(current);
    return numeric == null ? '$current+1' : '${numeric + 1}';
  }
}
