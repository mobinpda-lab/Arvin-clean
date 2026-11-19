import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ExclusionBackupService extends ArvinBackupService {
  Map<String, dynamic>? writtenPayload;
  Map<String, dynamic>? restoreDocument;

  @override
  String createBackupFileName(DateTime dateTime) => 'exclusions.json';

  @override
  Future<void> writeBackup({
    required String directoryUri,
    required Map<String, dynamic> payload,
    required String fileName,
    bool uploadToCloud = true,
    String? encryptionPassphrase,
  }) async {
    writtenPayload = payload;
  }

  @override
  Future<Map<String, dynamic>?> readBackup({String? passphrase}) async =>
      restoreDocument;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      ArvinBackupManager.directoryKey: 'content://arvin-backups',
    });
  });

  test('canonical backup and restore preserve Person Directory tombstones and unknown fields', () async {
    final service = _ExclusionBackupService();
    final manager = ArvinBackupManager(service: service);
    final exclusion = <String, dynamic>{
      'personId': 'person-removed-1',
      'excludedAt': '2026-11-19T08:30:00.000',
      'source': 'directory-user-action',
      'futureField': <String, dynamic>{'version': 2},
    };

    await manager.backupCanonicalTasks(
      const [],
      personDirectoryExclusions: [exclusion],
    );

    expect(service.writtenPayload?['personDirectoryExclusions'], [exclusion]);

    service.restoreDocument = <String, dynamic>{
      'type': ArvinBackupService.backupType,
      'formatVersion': ArvinBackupService.backupFormatVersion,
      'tasks': <Map<String, dynamic>>[],
      'personDirectoryExclusions': [exclusion],
    };
    final candidate = await manager.restoreCanonicalBackup();

    expect(candidate, isNotNull);
    expect(candidate!.hasPersonDirectoryExclusions, isTrue);
    expect(candidate.personDirectoryExclusions, [exclusion]);
    expect(candidate.personDirectoryExclusions!.single['futureField'], {
      'version': 2,
    });
  });

  test('legacy backup without tombstones remains distinguishable from explicit empty', () async {
    final service = _ExclusionBackupService();
    final manager = ArvinBackupManager(service: service);
    service.restoreDocument = <String, dynamic>{
      'type': ArvinBackupService.backupType,
      'formatVersion': ArvinBackupService.backupFormatVersion,
      'tasks': <Map<String, dynamic>>[],
    };

    final legacy = await manager.restoreCanonicalBackup();
    expect(legacy!.hasPersonDirectoryExclusions, isFalse);
    expect(legacy.personDirectoryExclusions, isNull);

    service.restoreDocument = <String, dynamic>{
      'type': ArvinBackupService.backupType,
      'formatVersion': ArvinBackupService.backupFormatVersion,
      'tasks': <Map<String, dynamic>>[],
      'personDirectoryExclusions': <Map<String, dynamic>>[],
    };
    final explicitEmpty = await manager.restoreCanonicalBackup();
    expect(explicitEmpty!.hasPersonDirectoryExclusions, isTrue);
    expect(explicitEmpty.personDirectoryExclusions, isEmpty);
  });

  test('restore rejects duplicate or malformed tombstone identities', () async {
    final service = _ExclusionBackupService();
    final manager = ArvinBackupManager(service: service);
    final valid = <String, dynamic>{
      'personId': 'person-removed-1',
      'excludedAt': '2026-11-19T08:30:00.000',
    };
    for (final entries in [
      [valid, valid],
      [
        <String, dynamic>{
          'personId': 'person-removed-2',
          'excludedAt': null,
        },
      ],
    ]) {
      service.restoreDocument = <String, dynamic>{
        'type': ArvinBackupService.backupType,
        'formatVersion': ArvinBackupService.backupFormatVersion,
        'tasks': <Map<String, dynamic>>[],
        'personDirectoryExclusions': entries,
      };
      await expectLater(
        manager.restoreCanonicalBackup(),
        throwsA(isA<FormatException>()),
      );
    }
  });

  test('active directory membership wins while local-only tombstones remain', () {
    final result =
        ArvinBackupManager.reconcilePersonDirectoryExclusionsById(
      current: const [
        {'personId': 'local-tombstone', 'excludedAt': '2026-01-01'},
        {'personId': 'now-active', 'excludedAt': '2026-01-02'},
      ],
      backup: const [
        {'personId': 'backup-tombstone', 'excludedAt': '2026-02-01'},
      ],
      activePersonIds: {'now-active'},
    );

    expect(result.map((entry) => entry['personId']).toSet(), {
      'local-tombstone',
      'backup-tombstone',
    });
  });
}
