import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/backup_service.dart';
import 'package:arvin/cloud_backup_provider.dart';

class _MemoryCloudProvider implements CloudBackupProvider {
  final Map<String, Uint8List> files = <String, Uint8List>{};

  @override
  Future<void> uploadBackup({
    required String fileName,
    required Uint8List bytes,
  }) async {
    files[fileName] = Uint8List.fromList(bytes);
  }

  @override
  Future<Uint8List?> downloadBackup(String fileName) async => files[fileName];

  @override
  Future<void> deleteBackup(String fileName) async {
    files.remove(fileName);
  }

  @override
  Future<bool> exists(String fileName) async => files.containsKey(fileName);
}

void main() {
  group('Backup cloud integration', () {
    test('uploads canonical backup bytes and restores them through the service', () async {
      final provider = _MemoryCloudProvider();
      final service = ArvinBackupService(cloudProvider: provider);
      final fileName = 'Arvin_Backup_1405-05-22_10-00.json';
      final bytes = ArvinBackupService.encodeBackupDocument({
        'tasks': [
          {
            'id': '1',
            'title': 'Cloud task',
            'completed': true,
          },
        ],
      });

      await provider.uploadBackup(fileName: fileName, bytes: bytes);

      final restored = await service.readCloudBackup(fileName);

      expect(restored, isNotNull);
      expect(restored!['type'], ArvinBackupService.backupType);
      expect(restored['formatVersion'], ArvinBackupService.backupFormatVersion);
      expect((restored['tasks'] as List).single['title'], 'Cloud task');
      expect((restored['tasks'] as List).single['completed'], isTrue);
    });

    test('rejects invalid cloud backup data using the same validator', () async {
      final provider = _MemoryCloudProvider();
      final service = ArvinBackupService(cloudProvider: provider);
      const fileName = 'invalid.json';
      await provider.uploadBackup(
        fileName: fileName,
        bytes: Uint8List.fromList(utf8.encode(jsonEncode({'type': 'wrong'}))),
      );

      expect(
        () => service.readCloudBackup(fileName),
        throwsA(isA<FormatException>()),
      );
    });

    test('returns null when the cloud backup does not exist', () async {
      final service = ArvinBackupService(cloudProvider: _MemoryCloudProvider());

      expect(await service.readCloudBackup('missing.json'), isNull);
    });

    test('delete removes a cloud backup', () async {
      final provider = _MemoryCloudProvider();
      final service = ArvinBackupService(cloudProvider: provider);
      final fileName = 'backup.json';
      await provider.uploadBackup(
        fileName: fileName,
        bytes: Uint8List.fromList(<int>[1, 2, 3]),
      );

      expect(await provider.exists(fileName), isTrue);
      await service.deleteCloudBackup(fileName);
      expect(await provider.exists(fileName), isFalse);
    });

    test('fails clearly when no cloud provider is configured', () async {
      final service = ArvinBackupService();

      expect(
        () => service.readCloudBackup('backup.json'),
        throwsA(isA<StateError>()),
      );
      expect(
        () => service.deleteCloudBackup('backup.json'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
