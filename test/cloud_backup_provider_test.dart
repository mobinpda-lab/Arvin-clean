import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/cloud_backup_provider.dart';

class _MemoryCloudBackupProvider implements CloudBackupProvider {
  final Map<String, Uint8List> _files = {};

  @override
  Future<void> uploadBackup({
    required String fileName,
    required Uint8List bytes,
  }) async {
    _files[fileName] = Uint8List.fromList(bytes);
  }

  @override
  Future<Uint8List?> downloadBackup(String fileName) async {
    final bytes = _files[fileName];
    return bytes == null ? null : Uint8List.fromList(bytes);
  }

  @override
  Future<void> deleteBackup(String fileName) async {
    _files.remove(fileName);
  }

  @override
  Future<bool> exists(String fileName) async => _files.containsKey(fileName);
}

void main() {
  test('cloud provider uploads and downloads backup bytes', () async {
    final provider = _MemoryCloudBackupProvider();
    final bytes = Uint8List.fromList([1, 2, 3, 4]);

    await provider.uploadBackup(fileName: 'backup.json', bytes: bytes);

    expect(await provider.exists('backup.json'), isTrue);
    expect(await provider.downloadBackup('backup.json'), orderedEquals(bytes));
  });

  test('cloud provider reports missing backup', () async {
    final provider = _MemoryCloudBackupProvider();

    expect(await provider.exists('missing.json'), isFalse);
    expect(await provider.downloadBackup('missing.json'), isNull);
  });

  test('cloud provider deletes a backup', () async {
    final provider = _MemoryCloudBackupProvider();

    await provider.uploadBackup(
      fileName: 'backup.json',
      bytes: Uint8List.fromList([7, 8]),
    );
    await provider.deleteBackup('backup.json');

    expect(await provider.exists('backup.json'), isFalse);
    expect(await provider.downloadBackup('backup.json'), isNull);
  });
}
