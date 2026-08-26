import 'dart:convert';

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
