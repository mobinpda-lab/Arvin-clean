import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import '../models/task.dart';
import 'sync_merge_service.dart';

/// Derives transport-neutral sync revision evidence from the canonical Task.
///
/// This adapter performs no persistence or network work. It fingerprints the
/// existing `Task.toJson()` representation so the merge-decision service can
/// compare records without introducing a second task model or storage path.
class TaskSyncRevisionService {
  TaskSyncRevisionService({HashAlgorithm? hashAlgorithm})
      : _hashAlgorithm = hashAlgorithm ?? Sha256();

  final HashAlgorithm _hashAlgorithm;

  Future<SyncRevision> fromTask(Task task) async {
    if (task.id.isEmpty) {
      throw ArgumentError.value(task.id, 'task.id', 'Task id must not be empty.');
    }

    final canonicalJson = jsonEncode(task.toJson());
    final hash = await _hashAlgorithm.hash(utf8.encode(canonicalJson));

    return SyncRevision(
      id: task.id,
      fingerprint: _toHex(hash.bytes),
      modifiedAt: task.updatedAt ?? task.createdAt,
    );
  }

  String _toHex(List<int> bytes) {
    final buffer = StringBuffer();
    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
