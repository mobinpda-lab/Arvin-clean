import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/backup_service.dart';

void main() {
  group('ArvinBackupService', () {
    final service = ArvinBackupService();

    test('creates a Persian-date backup filename', () {
      final name = service.createBackupFileName(DateTime(2026, 8, 12, 9, 13));
      expect(name, 'Arvin_Backup_1405-05-21_09-13.json');
    });

    test('creates zero-padded backup time', () {
      final name = service.createBackupFileName(DateTime(2026, 1, 2, 3, 4));
      expect(name, 'Arvin_Backup_1404-10-12_03-04.json');
    });

    test('accepts a valid backup document', () {
      final document = ArvinBackupService.validateBackupDocument({
        'type': 'arvin_backup',
        'formatVersion': 1,
        'createdAt': '2026-08-12T15:00:00Z',
        'tasks': <dynamic>[],
      });

      expect(document['type'], 'arvin_backup');
      expect(document['formatVersion'], 1);
      expect(document['tasks'], isEmpty);
      expect(document.containsKey('settings'), isFalse);
    });

    test('keeps existing task-only v1 backups backward compatible', () {
      final document = ArvinBackupService.validateBackupDocument({
        'type': 'arvin_backup',
        'formatVersion': 1,
        'createdAt': '2026-08-12T15:00:00Z',
        'tasks': <dynamic>[
          <String, dynamic>{'id': 'legacy', 'title': 'old backup'},
        ],
      });

      expect(document['tasks'], hasLength(1));
      expect(document.containsKey('settings'), isFalse);
    });

    test('encodes and validates optional settings in the same v1 document', () {
      final bytes = ArvinBackupService.encodeBackupDocument({
        'tasks': <dynamic>[],
        'settings': <String, dynamic>{
          'themeMode': 'dark',
          'usePersianDate': true,
          'fontFamily': 'Vazirmatn',
        },
      });
      final decoded = jsonDecode(utf8.decode(bytes));
      final document = ArvinBackupService.validateBackupDocument(decoded);

      expect(document['formatVersion'], 1);
      expect(document['settings'], {
        'themeMode': 'dark',
        'usePersianDate': true,
        'fontFamily': 'Vazirmatn',
      });
    });

    test('round-trips optional Calendar links, Category/Tag catalogs and People directory', () {
      final bytes = ArvinBackupService.encodeBackupDocument({
        'tasks': <dynamic>[
          <String, dynamic>{'id': 'task-1', 'title': 'کار نمونه'},
        ],
        'calendarLinks': <Map<String, dynamic>>[
          <String, dynamic>{
            'reminderId': 'task-due:task-1',
            'calendarId': 'calendar-1',
            'eventId': 'event-1',
            'lastSyncedFingerprint': 'fingerprint-1',
          },
        ],
        'categories': <String>['خانه', 'مالی'],
        'tags': <String>['مهم', 'پیگیری'],
        'peopleDirectory': <Map<String, dynamic>>[
          <String, dynamic>{'id': 'person-1', 'displayName': 'سارا احمدی'},
        ],
        'personDirectoryExclusions': <Map<String, dynamic>>[
          <String, dynamic>{
            'personId': 'person-removed',
            'excludedAt': '2026-11-19T09:00:00.000',
          },
        ],
      });
      final document = ArvinBackupService.validateBackupDocument(
        jsonDecode(utf8.decode(bytes)),
      );

      expect(document['calendarLinks'], hasLength(1));
      expect(
        (document['calendarLinks'] as List).single['eventId'],
        'event-1',
      );
      expect(document['categories'], <String>['خانه', 'مالی']);
      expect(document['tags'], <String>['مهم', 'پیگیری']);
      expect(document['peopleDirectory'], [
        <String, dynamic>{'id': 'person-1', 'displayName': 'سارا احمدی'},
      ]);
      expect(document['personDirectoryExclusions'], [
        <String, dynamic>{
          'personId': 'person-removed',
          'excludedAt': '2026-11-19T09:00:00.000',
        },
      ]);
    });

    test('rejects malformed optional Calendar link and taxonomy containers', () {
      for (final key in ['calendarLinks', 'categories', 'tags', 'peopleDirectory', 'personDirectoryExclusions']) {
        expect(
          () => ArvinBackupService.encodeBackupDocument({
            'tasks': <dynamic>[],
            key: 'not-a-list',
          }),
          throwsA(isA<FormatException>()),
        );
        expect(
          () => ArvinBackupService.validateBackupDocument({
            'type': 'arvin_backup',
            'formatVersion': 1,
            'tasks': <dynamic>[],
            key: 'not-a-list',
          }),
          throwsA(isA<FormatException>()),
        );
      }
    });

    test('rejects duplicate or simultaneously active person exclusions', () {
      final duplicate = <Map<String, dynamic>>[
        <String, dynamic>{
          'personId': 'person-removed',
          'excludedAt': '2026-11-19T09:00:00.000',
        },
        <String, dynamic>{
          'personId': 'person-removed',
          'excludedAt': '2026-11-19T10:00:00.000',
        },
      ];
      expect(
        () => ArvinBackupService.encodeBackupDocument({
          'tasks': <dynamic>[],
          'personDirectoryExclusions': duplicate,
        }),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => ArvinBackupService.validateBackupDocument({
          'type': 'arvin_backup',
          'formatVersion': 1,
          'tasks': <dynamic>[],
          'peopleDirectory': <Map<String, dynamic>>[
            <String, dynamic>{'id': 'person-removed', 'displayName': 'شخص'},
          ],
          'personDirectoryExclusions': <Map<String, dynamic>>[
            <String, dynamic>{
              'personId': 'person-removed',
              'excludedAt': '2026-11-19T09:00:00.000',
            },
          ],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('real write and read byte path preserves exclusions, unknown fields and explicit nulls', () async {
      Uint8List? writtenBytes;
      final fileService = ArvinBackupService(
        localWriter: (_, __, ___, bytes) async {
          writtenBytes = bytes;
        },
      );
      final exclusion = <String, dynamic>{
        'personId': 'person-removed-real-bytes',
        'excludedAt': '2026-11-19T10:15:00.000',
        'futureField': <String, dynamic>{'revision': 3},
      };
      await fileService.writeBackup(
        directoryUri: 'content://arvin-backups',
        fileName: 'real-roundtrip.json',
        uploadToCloud: false,
        payload: <String, dynamic>{
          'tasks': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'task-roundtrip',
              'title': 'کار آزمایشی',
              'legacy_payload_json': null,
              'futureTaskField': <String, dynamic>{'kept': true},
            },
          ],
          'personDirectoryExclusions': <Map<String, dynamic>>[exclusion],
        },
      );
      expect(writtenBytes, isNotNull);
      final restored = await fileService.decodeBackupBytes(writtenBytes!);
      expect(restored['personDirectoryExclusions'], [exclusion]);
      expect((restored['tasks'] as List).single['legacy_payload_json'], isNull);
      expect((restored['tasks'] as List).single['futureTaskField'], {'kept': true});
    });

    test('rejects invalid settings payload without creating a new format', () {
      expect(
        () => ArvinBackupService.encodeBackupDocument({
          'tasks': <dynamic>[],
          'settings': 'not-a-map',
        }),
        throwsA(isA<FormatException>()),
      );

      expect(
        () => ArvinBackupService.validateBackupDocument({
          'type': 'arvin_backup',
          'formatVersion': 1,
          'tasks': <dynamic>[],
          'settings': <dynamic>[],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a non-map backup document', () {
      expect(
        () => ArvinBackupService.validateBackupDocument(<dynamic>[]),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a backup with the wrong type', () {
      expect(
        () => ArvinBackupService.validateBackupDocument({
          'type': 'other_app',
          'formatVersion': 1,
          'tasks': <dynamic>[],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects an unsupported backup version', () {
      expect(
        () => ArvinBackupService.validateBackupDocument({
          'type': 'arvin_backup',
          'formatVersion': 2,
          'tasks': <dynamic>[],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects invalid tasks data', () {
      expect(
        () => ArvinBackupService.validateBackupDocument({
          'type': 'arvin_backup',
          'formatVersion': 1,
          'tasks': 'not-a-list',
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
