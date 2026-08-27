import 'dart:convert';
import 'dart:typed_data';

import 'package:arvin/backup_service.dart';
import 'package:arvin/cloud_backup_provider.dart';
import 'package:arvin/services/encrypted_backup_envelope.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryCloudProvider implements CloudBackupProvider {
  final Map<String, Uint8List> files = <String, Uint8List>{};
  Uint8List? lastUploadedBytes;

  @override
  Future<void> uploadBackup({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final copy = Uint8List.fromList(bytes);
    lastUploadedBytes = copy;
    files[fileName] = copy;
  }

  @override
  Future<Uint8List?> downloadBackup(String fileName) async {
    final bytes = files[fileName];
    return bytes == null ? null : Uint8List.fromList(bytes);
  }

  @override
  Future<void> deleteBackup(String fileName) async {
    files.remove(fileName);
  }

  @override
  Future<bool> exists(String fileName) async => files.containsKey(fileName);
}

ArvinEncryptedBackupEnvelope _fastEnvelope() {
  return ArvinEncryptedBackupEnvelope(
    memoryKiB: ArvinEncryptedBackupEnvelope.minMemoryKiB,
    iterations: 1,
    parallelism: 1,
  );
}

Map<String, dynamic> _payload() => <String, dynamic>{
      'tasks': <dynamic>[
        <String, dynamic>{'id': 'task-1', 'title': 'پیگیری قرارداد'},
      ],
      'settings': <String, dynamic>{
        'themeMode': 'dark',
        'usePersianDate': true,
      },
    };

void main() {
  group('ArvinBackupService encrypted byte path', () {
    test('keeps plaintext v1 as the default byte path', () async {
      final service = ArvinBackupService(encryptedEnvelope: _fastEnvelope());

      final bytes = await service.prepareBackupBytes(_payload());
      final decoded = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;

      expect(decoded['type'], ArvinBackupService.backupType);
      expect(decoded['formatVersion'], ArvinBackupService.backupFormatVersion);
      expect(decoded['tasks'], hasLength(1));
    });

    test('local and cloud receive the exact same encrypted bytes', () async {
      final cloud = _MemoryCloudProvider();
      Uint8List? localBytes;
      final service = ArvinBackupService(
        cloudProvider: cloud,
        encryptedEnvelope: _fastEnvelope(),
        localWriter: (directoryUri, fileName, mimeType, bytes) async {
          expect(directoryUri, 'content://backup-root');
          expect(fileName, 'backup.json');
          expect(mimeType, 'application/json');
          localBytes = Uint8List.fromList(bytes);
        },
      );

      await service.writeBackup(
        directoryUri: 'content://backup-root',
        payload: _payload(),
        fileName: 'backup.json',
        encryptionPassphrase: 'portable-passphrase',
      );

      expect(localBytes, isNotNull);
      expect(cloud.lastUploadedBytes, isNotNull);
      expect(cloud.lastUploadedBytes, orderedEquals(localBytes!));

      final envelope = jsonDecode(utf8.decode(localBytes!)) as Map<String, dynamic>;
      expect(envelope['type'], ArvinEncryptedBackupEnvelope.envelopeType);
      expect(utf8.decode(localBytes!), isNot(contains('پیگیری قرارداد')));
    });

    test('encrypted cloud restore authenticates then uses v1 validator', () async {
      final cloud = _MemoryCloudProvider();
      final service = ArvinBackupService(
        cloudProvider: cloud,
        encryptedEnvelope: _fastEnvelope(),
      );
      final encrypted = await service.prepareBackupBytes(
        _payload(),
        passphrase: 'restore-passphrase',
      );
      cloud.files['backup.json'] = Uint8List.fromList(encrypted);

      final restored = await service.readCloudBackup(
        'backup.json',
        passphrase: 'restore-passphrase',
      );

      expect(restored, isNotNull);
      expect(restored!['type'], ArvinBackupService.backupType);
      expect(restored['tasks'], hasLength(1));
      expect(restored['settings'], isA<Map<String, dynamic>>());
    });

    test('legacy plaintext backup still restores without a passphrase', () async {
      final service = ArvinBackupService(encryptedEnvelope: _fastEnvelope());
      final legacyBytes = ArvinBackupService.encodeBackupDocument(_payload());

      final restored = await service.decodeBackupBytes(legacyBytes);

      expect(restored['type'], ArvinBackupService.backupType);
      expect(restored['tasks'], hasLength(1));
    });

    test('wrong passphrase fails before a document is returned', () async {
      final service = ArvinBackupService(encryptedEnvelope: _fastEnvelope());
      final encrypted = await service.prepareBackupBytes(
        _payload(),
        passphrase: 'right-passphrase',
      );

      expect(
        () => service.decodeBackupBytes(
          encrypted,
          passphrase: 'wrong-passphrase',
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('empty passphrase cannot silently enable encryption', () async {
      final service = ArvinBackupService(encryptedEnvelope: _fastEnvelope());

      expect(
        () => service.prepareBackupBytes(_payload(), passphrase: '   '),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
